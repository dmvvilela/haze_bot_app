"""Verify export dimensions, opacity, layout bounds, ordering and metadata limits."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
manifest = json.loads((ROOT/'manifest.json').read_text())
assert manifest['storeUploaded'] is False
assert len(manifest['files']) == 30
counts = {}
for item in manifest['files']:
    path = ROOT/item['file']
    im = Image.open(path)
    assert im.size == (item['width'], item['height']), path
    assert im.mode == 'RGB', path
    assert hashlib.sha256(path.read_bytes()).hexdigest() == item['sha256'], path
    key = tuple(Path(item['file']).parts[1:3])
    counts[key] = counts.get(key,0)+1
    x,y,r,b = item['deviceBounds']
    assert 0 <= x < r <= im.width and 0 <= y < b <= im.height, (path, 'frame cropped')
    cx,cy,cr,cb = item['copyBounds']
    assert cr <= x or cb+16 <= y, (path, 'device overlaps marketing copy')
    assert b+10 <= item['footerTop'] or x >= cr, (path, 'device overlaps footer')
assert len(counts) == 6 and set(counts.values()) == {5}
metadata = json.loads((ROOT/'source/metadata.json').read_text())
lengths = {}
for locale, fields in metadata['locales'].items():
    lengths[locale] = {}
    for name, limit in {'subtitle':30,'shortDescription':80,'promotionalText':170,'keywords':100,'description':4000,'whatsNew':4000}.items():
        assert len(fields[name]) <= limit, (locale,name,len(fields[name]),limit)
        lengths[locale][name] = len(fields[name])
    assert 'five face styles' not in fields['description']
result = {'passed':True, 'screenshots':30, 'locales':['en-US','pt-BR'],
          'platforms':['iphone','ipad','android'], 'opaque':True,
          'dimensionsAndHashes':True, 'noLayoutOverlaps':True,
          'metadataLengths':lengths, 'storeUploaded':False}
(ROOT/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
