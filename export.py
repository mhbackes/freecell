#!/usr/bin/env python3
import argparse, subprocess

PROJECT_NAME="Freecell"

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("target", choices=["debug", "release"], nargs="?", default="debug")
    parser.add_argument("arch", choices=["android", "linux", "web", "windows"], nargs="?", default="linux")

    args = parser.parse_args()
    print(f"Target: {args.target}, Architecture: {args.arch}")

    path = f"build/{args.target}/{args.arch}"
    make_path = f"mkdir -p {path}"
    subprocess.run(make_path, shell=True)
    ext = ".apk" if args.arch == "android" else ".x86_64"
    output_file = f"{path}/{PROJECT_NAME}{ext}"

    command = f"godot --headless --export-{args.target} '{args.arch}' {output_file}"
    print(command)
    subprocess.run(command, shell=True)

if __name__ == "__main__":
    main()
