"""Build GameMaker CSVs and fixtures from one verified Unicode Character Database release."""
import argparse
import csv
import hashlib
import json
import os
import re
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from urllib.request import urlopen

root = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--input-dir', type=Path, default=root, help='Directory containing the cached UCD text files.')
parser.add_argument('--project-dir', type=Path, default=root.parent / 'source/Toolbox', help='GameMaker project whose datafiles directory receives the tables.')
parser.add_argument('--fixture-dir', type=Path, default=root, help='Directory for the generated conformance fixtures.')
parser.add_argument('--fetch', action='store_true', help='Fetch missing or invalid cached files from the pinned Unicode URLs.')
args = parser.parse_args()
work = args.input_dir
fixtures = args.fixture_dir
project = args.project_dir
out = project / 'datafiles/Unicode'
sources = json.loads((root / 'sources.json').read_text(encoding='utf-8'))


def verified_file(url, target, expected, fallback=None):
    """Resolve a pinned file from a verified cache or an explicit download."""
    for candidate in (target, fallback):
        if candidate is not None and candidate.is_file():
            content = candidate.read_bytes()
            if hashlib.sha256(content).hexdigest() == expected:
                return content
    if not args.fetch:
        raise SystemExit(f'Missing or invalid Unicode {sources["version"]} source: {target}. Use --fetch to restore it.')
    with urlopen(url, timeout=30) as response:
        content = response.read()
    if hashlib.sha256(content).hexdigest() != expected:
        raise SystemExit(f'Unicode source checksum mismatch: {url}. The cache was preserved.')
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=target.parent, delete=False) as handle:
        stage = Path(handle.name)
        try:
            handle.write(content)
            handle.close()
            os.replace(stage, target)
        finally:
            stage.unlink(missing_ok=True)
    return content


def fetch(relative):
    return verified_file(sources['url'] + relative, work / Path(relative).name, sources['sha256'][relative])


with ThreadPoolExecutor(max_workers=4) as pool:
    list(pool.map(fetch, sources['sha256']))
license_source = sources['license']
license_file = out / 'Unicode-license.txt'
license_text = verified_file(license_source['url'], work / license_file.name, license_source['sha256'],
                             root / license_file.name)
(out / 'Planes').mkdir(parents=True, exist_ok=True)
fixtures.mkdir(parents=True, exist_ok=True)
license_file.write_bytes(license_text)

def records(filename):
    for line in (work/filename).read_text().splitlines():
        line=line.partition('#')[0].strip()
        if not line:continue
        field,*rest=map(str.strip,line.split(';'))
        lo,_,hi=field.partition('..')
        yield int(lo,16),int(hi or lo,16),rest

# Low byte indexes the grapheme class. The remaining bits carry independent properties.
classes=['Other','CR','LF','Control','Extend','ZWJ','Regional_Indicator','Prepend',
         'SpacingMark','L','V','T','LV','LVT']
props=[0]*0x110000
for lo,hi,fields in records('GraphemeBreakProperty.txt'):
    props[lo:hi+1]=[classes.index(fields[0])]*(hi-lo+1)
for filename in ('emoji-data.txt','DerivedCoreProperties.txt'):
    for lo,hi,fields in records(filename):
        if fields[0]=='Extended_Pictographic':flag=256
        elif fields[0]=='InCB':flag={'Linker':512,'Extend':1024,'Consonant':2048}[fields[1]]
        else:continue
        for cp in range(lo,hi+1):props[cp]|=flag
word_classes = ['Other','CR','LF','Newline','Extend','Format','ZWJ','WSegSpace','ALetter','Hebrew_Letter',
                'Numeric','Katakana','ExtendNumLet','MidLetter','MidNum','MidNumLet','Single_Quote',
                'Double_Quote','Regional_Indicator']
for lo,hi,fields in records('WordBreakProperty.txt'):
    word=word_classes.index(fields[0])<<12
    for cp in range(lo,hi+1):props[cp]|=word
cats=['Cn','Lu','Ll','Lt','Lm','Lo','Mn','Mc','Me','Nd','Nl','No','Pc','Pd','Ps','Pe','Pi','Pf','Po',
      'Sm','Sc','Sk','So','Zs','Zl','Zp','Cc','Cf','Cs','Co']
case_map={}
canonical={}
first=None
for line in (work/'UnicodeData.txt').read_text().splitlines():
    fields=line.split(';');cp=int(fields[0],16);category=cats.index(fields[2])<<17
    if fields[1].endswith(', First>'):
        first=cp;continue
    lo=first if fields[1].endswith(', Last>') else cp
    for c in range(lo,cp+1):props[c]|=category
    first=None
    rank = int(fields[3])
    decomp = fields[5]
    points = tuple(int(unit, 16) for unit in decomp.split()) if decomp and not decomp.startswith('<') else ()
    if rank or points:
        canonical[cp] = (rank, points)
    mappings=[fields[13],fields[12],fields[14] or fields[12]]
    if any(mappings):case_map[cp]=[[int(m,16)] if m else [cp] for m in mappings]
for line in (work/'SpecialCasing.txt').read_text().splitlines():
    fields=[f.strip() for f in line.partition('#')[0].split(';')]
    if len(fields)<5 or fields[4]:continue
    cp=int(fields[0],16)
    case_map[cp]=[[int(v,16) for v in f.split()] for f in (fields[1],fields[3],fields[2])]
for file in ('PropList.txt','DerivedCoreProperties.txt'):
    for lo,hi,fields in records(file):
        mask={'White_Space':1<<22,'Cased':1<<23,'Case_Ignorable':1<<24}.get(fields[0],0)
        if mask:
            for cp in range(lo,hi+1):props[cp]|=mask
with (out/'case-mappings.csv').open('w',newline='') as handle:
    writer=csv.writer(handle,lineterminator='\n')
    for cp,columns in sorted(case_map.items()):writer.writerow([cp]+[' '.join(map(str,c)) for c in columns])
# Unicode full default folding uses common and full mappings and omits locale-specific Turkic mappings.
folds = {}
for cp, _, fields in records('CaseFolding.txt'):
    if fields[0] in ('C', 'F'):
        folds[cp] = ' '.join(str(int(unit, 16)) for unit in fields[1].split())
with (out/'case-folding.csv').open('w', newline='') as handle:
    writer = csv.writer(handle, lineterminator='\n')
    writer.writerows(sorted(folds.items()))
excluded_composites = set()
for lo, hi, fields in records('DerivedNormalizationProps.txt'):
    if fields[0] == 'Full_Composition_Exclusion':
        excluded_composites.update(range(lo, hi+1))
with (out/'canonical-normalization.csv').open('w', newline='') as handle:
    writer = csv.writer(handle, lineterminator='\n')
    for cp, (rank, points) in sorted(canonical.items()):
        mapping = ' '.join(map(str, points)) or '-'
        compose = len(points) == 2 and cp not in excluded_composites
        writer.writerow((cp, rank, mapping, int(compose)))

normalization_cases = []
for line in (work/'NormalizationTest.txt').read_text().splitlines():
    line = line.partition('#')[0].strip()
    if line and not line.startswith('@'):
        columns = line.split(';')[:5]
        normalization_cases.append([''.join(chr(int(unit, 16)) for unit in field.split()) for field in columns])
(fixtures/'normalization-tests.json').write_text(
    json.dumps(normalization_cases, ensure_ascii=False, separators=(',', ':'))+'\n', encoding='utf-8')
print('NormalizationTest.txt', len(normalization_cases))

with (out/'text-properties.csv').open('w',newline='') as stream:
    writer=csv.writer(stream,lineterminator='\n')
    start=0
    for i in range(1,len(props)+1):
        if i==len(props) or props[start]!=props[i]:
            if props[start]:writer.writerow((start,i-1,props[start]))
            start=i
for filename,output_name in [('GraphemeBreakTest.txt','grapheme-tests.json'),('WordBreakTest.txt','word-tests.json')]:
    cases=[]
    for line in (work/filename).read_text().splitlines():
        fields=line.partition('#')[0].split()
        if not fields:continue
        points=[];boundaries=[]
        for field in fields:
            if field=='÷':boundaries.append(len(points))
            elif field!='×':points.append(int(field,16))
        cases.append([points,boundaries])
    (fixtures/output_name).write_text(json.dumps(cases,separators=(',',':'))+'\n')
    print(filename, len(cases))

# Use one set of expanded records for both legacy lookup modes. UnicodeData lists
# only the boundaries of some assigned ranges, including the ideographs and Hangul.
raw_rows={}
range_rows=[]
for line in (work/'UnicodeData.txt').read_text().splitlines():
    row=line.split(';')
    cp=int(row[0],16)
    raw_rows[cp]=row
    if row[1].endswith(', First>'):first=cp
    elif row[1].endswith(', Last>'):range_rows.append((first,cp,raw_rows[first]))
names={}
for lo,hi,fields in records('DerivedName.txt'):
    for cp in range(lo,hi+1):names[cp]=fields[0].replace('*',f'{cp:04X}')
numerics={}
for lo,hi,fields in records('DerivedNumericValues.txt'):
    for cp in range(lo,hi+1):numerics[cp]=fields[2]
bidi=['L']*0x110000
short={'Left_To_Right':'L','Right_To_Left':'R','Arabic_Letter':'AL','European_Terminator':'ET'}
for match in re.finditer(r'# @missing: ([0-9A-F]+)\.\.([0-9A-F]+); (\w+)',(work/'DerivedBidiClass.txt').read_text()):
    lo,hi=[int(v,16) for v in match.group(1,2)]
    bidi[lo:hi+1]=[short[match[3]]]*(hi-lo+1)
for lo,hi,fields in records('DerivedBidiClass.txt'):bidi[lo:hi+1]=[fields[0]]*(hi-lo+1)
noncharacters = set()
for lo, hi, fields in records('PropList.txt'):
    if fields[0] == 'Noncharacter_Code_Point':
        noncharacters.update(range(lo, hi + 1))

cursor=0
compact_count=0
with (out/'UnicodeData.csv').open('w', newline='') as compact_stream:
    compact=csv.writer(compact_stream, lineterminator='\n')
    for plane in range(17):
        with (out/'Planes'/f'Unicode Plane {plane}.csv').open('w', newline='') as stream:
            dense=csv.writer(stream, lineterminator='\n')
            for cp in range(plane << 16, (plane + 1) << 16):
                while cursor<len(range_rows) and cp>range_rows[cursor][1]:
                    cursor+=1
                if cp in raw_rows:
                    row=raw_rows[cp].copy()
                elif cursor<len(range_rows) and range_rows[cursor][0]<cp<range_rows[cursor][1]:
                    row=range_rows[cursor][2].copy()
                else:
                    label='<noncharacter>' if cp in noncharacters else '<unassigned>'
                    row=['',label,'Cn','0',bidi[cp],'','','','','N','','','','','']
                row[0]=f'{cp:04X}'
                if row[2] in ('Cs', 'Co'):
                    row[1]={'Cs':'<surrogate>','Co':'<private-use>'}[row[2]]
                row[1]=names.get(cp,row[1])
                row[8]=numerics.get(cp,row[8])
                record=[f'{cp:08X}',cp,*row,cp]
                dense.writerow(record)
                if row[2]!='Cn':
                    compact.writerow(record)
                    compact_count+=1
print('UnicodeData.csv', compact_count, 'assigned-category rows')
