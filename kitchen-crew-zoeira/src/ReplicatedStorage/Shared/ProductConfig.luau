-- ID = 0 significa que nenhuma compra real sera exibida.
-- Crie os Developer Products em Creator Dashboard e substitua cada productId.
local ProductConfig = {
    {key = "pie5", name = "5 Tortas", price = 19, productId = 0, grants = {pie = 5}},
    {key = "pie10", name = "10 Tortas", price = 29, productId = 0, grants = {pie = 10}},
    {key = "pie25", name = "25 Tortas", price = 59, productId = 0, grants = {pie = 25}},
    {key = "trapPack", name = "Pacote Armadilhas", price = 29, productId = 0, grants = {banana = 5, confetti = 3}},
    {key = "gravityPack", name = "Pacote Gravidade", price = 19, productId = 0, grants = {upsideDown = 3}},
    {key = "partyPack", name = "Festa na Cozinha", price = 39, productId = 0, grants = {confetti = 4, musicalPot = 3, spaghettiRain = 3}},
    {key = "chaosPack", name = "Caos Total", price = 99, productId = 0, grants = {pie = 10, banana = 5, confetti = 5, bigHead = 5, upsideDown = 5}},
    {key = "cornerTime", name = "10 min Cantinho", price = 29, productId = 0, grants = {cornerSeconds = 600}}
}

local byId = {}
local byKey = {}
for _, product in ipairs(ProductConfig) do
    byKey[product.key] = product
    if product.productId ~= 0 then
        assert(byId[product.productId] == nil, "Developer Product ID duplicado")
        byId[product.productId] = product
    end
end

return {list = ProductConfig, byId = byId, byKey = byKey}
