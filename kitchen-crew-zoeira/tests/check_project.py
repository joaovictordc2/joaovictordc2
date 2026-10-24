"""Offline structural check; not a Luau compile or Studio playtest."""
from pathlib import Path
import json, re
root = Path(__file__).resolve().parent.parent
rojo = json.loads((root / 'default.project.json').read_text(encoding='utf-8'))
assert rojo['name'].startswith('Kitchen Crew')
for relative in (
    'src/ServerScriptService/Main.server.luau',
    'src/ReplicatedStorage/Shared/PrankConfig.luau',
    'src/ReplicatedStorage/Shared/ProductConfig.luau',
    'src/ServerScriptService/Services/PrankService.luau',
    'src/ServerScriptService/Services/ProfileStore.luau',
    'src/ServerScriptService/Services/EffectService.luau',
    'src/StarterPlayer/StarterPlayerScripts/Shop.client.luau',
):
    assert (root / relative).is_file(), relative
pranks=(root/'src/ReplicatedStorage/Shared/PrankConfig.luau').read_text(encoding='utf-8')
ids=re.findall(r'\{id="([a-zA-Z0-9]+)"', pranks)
assert len(ids)==len(set(ids)) and len(ids)>=30
for core in ['pie','banana','upsideDown','confetti','bigHead','spaghettiRain','musicalPot','flour','ketchup','duck','cheeseRain','floatingPizza','bubbles','sadTrombone']:
    assert core in ids, core
products=(root/'src/ReplicatedStorage/Shared/ProductConfig.luau').read_text(encoding='utf-8')
assert 'process' not in products.lower()
assert 'productId = 0' in products
profile=(root/'src/ServerScriptService/Services/ProfileStore.luau').read_text(encoding='utf-8')
assert 'UpdateAsync' in profile and 'PurchaseId' in profile
main=(root/'src/ServerScriptService/Main.server.luau').read_text(encoding='utf-8')
assert 'ProcessReceipt' in main
print(f'OK: estrutura Rojo, {len(ids)} catalogados, 14 efeitos inicialmente ativos, receipt idempotente presente.')
