import subprocess

from canvas import CONTAINER


def snap(ids, out, scale=1.0):
    """Exports the ids as SVG on the canvas (its PNG renderer crashes on big regions) and rasterises locally."""
    name = out.rsplit("/", 1)[-1].rsplit(".", 1)[0]
    for _ in range(3):
        r = subprocess.run(["docker", "exec", CONTAINER, "node", "dist/bin.js", "screenshot", "--renderer",
                            "node", "--format", "svg", "--ids", ",".join(ids), "--out", f"/tmp/{name}.svg"],
                           capture_output=True, text=True)
        if not r.returncode:
            break
    if r.returncode:
        print(r.stdout[:300], r.stderr[:300])
    svg = out.rsplit(".", 1)[0] + ".svg"
    subprocess.run(["docker", "cp", f"{CONTAINER}:/tmp/{name}.svg", svg], check=True, capture_output=True)
    subprocess.run(["rsvg-convert", "-z", str(scale), "-b", "white", "-o", out, svg], check=True, capture_output=True)
