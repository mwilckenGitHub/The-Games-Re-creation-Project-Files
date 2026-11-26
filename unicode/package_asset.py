"""Build the Unicode With String Functions GameMaker local asset package."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


def read_metadata(data):
    return json.loads(re.sub(r'("(?:\\.|[^"\\])*")|,(?=\s*[}\]])', lambda match: match[1] or "", data.decode("utf-8-sig")))


def json_bytes(data):
    return (json.dumps(data, indent=2, ensure_ascii=False) + "\n").encode()


def add_file(archive, name, content):
    entry = ZipInfo(name, (1980, 1, 1, 0, 0, 0))
    entry.compress_type = ZIP_DEFLATED
    entry.external_attr = 0o100644 << 16
    archive.writestr(entry, content)


def build_archive(template, scripts, project, output):
    name = "Unicode With String Functions"
    version = "1.1.0"
    asset_names = ("Unicode", "Unicode_text", "Text_properties", "Graphemes", "Word_breaks")
    with ZipFile(template) as archive:
        metadata = read_metadata(archive.read("metadata.json"))
        manifest = read_metadata(archive.read(f"{name}.yyp"))

    metadata.update(version=version, ide_version="2026.1.0.27")
    manifest["MetaData"].update(PackageVersion=version, IDEVersion=metadata["ide_version"])
    manifest["AudioGroups"] = [group for group in manifest["AudioGroups"] if group["name"] == "audiogroup_default"]
    folder = manifest["Folders"][0]
    parent = {"name": folder["name"], "path": folder["folderPath"]}
    order = {"FolderOrderSettings": [{"name": parent["name"], "path": parent["path"], "order": 0}],
             "ResourceOrderSettings": []}
    manifest["resources"] = []
    files = {"metadata.json": json_bytes(metadata)}

    for index, asset in enumerate(asset_names):
        path = f"scripts/{asset}/{asset}.yy"
        descriptor = read_metadata((scripts / asset / f"{asset}.yy").read_bytes())
        descriptor["parent"] = parent
        files[path] = json_bytes(descriptor)
        files[f"scripts/{asset}/{asset}.gml"] = (scripts / asset / f"{asset}.gml").read_bytes()
        manifest["resources"].append({"id": {"name": asset, "path": path}})
        order["ResourceOrderSettings"].append({"name": asset, "path": path, "order": index})

    data_root = project / "datafiles" / "Unicode"
    included = ["UnicodeData.csv", "text-properties.csv", "case-mappings.csv", "case-folding.csv",
                "canonical-normalization.csv", "Unicode-license.txt"]
    included += [f"Planes/Unicode Plane {plane}.csv" for plane in range(17)]
    manifest["IncludedFiles"] = []
    for filename in included:
        relative = Path("datafiles/Unicode") / filename
        files[relative.as_posix()] = (data_root / filename).read_bytes()
        manifest["IncludedFiles"].append({"$GMIncludedFile": "", "%Name": relative.name, "CopyToMask": -1,
            "filePath": relative.parent.as_posix(), "name": relative.name, "resourceType": "GMIncludedFile",
            "resourceVersion": "2.0"})

    files[f"{name}.yyp"] = json_bytes(manifest)
    files[f"{name}.resource_order"] = json_bytes(order)
    index = ET.Element("files")
    for path, content in files.items():
        record = ET.SubElement(index, "file", md5=hashlib.md5(content, usedforsecurity=False).hexdigest().upper())
        record.text = path.replace("/", "\\")
    ET.indent(index, space="\t")
    files["yymanifest.xml"] = b"\xef\xbb\xbf" + ET.tostring(index, encoding="utf-8", xml_declaration=True)

    with ZipFile(output, "x") as archive:
        for path, content in files.items():
            add_file(archive, path, content)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-package", type=Path, required=True, help="Original asset package with GameMaker package metadata.")
    parser.add_argument("--scripts", type=Path, required=True, help="Directory of GameMaker script assets.")
    parser.add_argument("--project-dir", type=Path, required=True, help="Directory holding the generated datafiles tree.")
    parser.add_argument("--output", type=Path, required=True, help="New .yymps file.")
    args = parser.parse_args()
    build_archive(args.base_package, args.scripts, args.project_dir, args.output)
