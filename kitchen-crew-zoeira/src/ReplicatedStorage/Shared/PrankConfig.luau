local defs = {
    -- Implementacoes jogaveis desta entrega
    {id="pie", name="Tortada na Cara", category="Pegadinhas", cost=15, duration=10, disrupt=false, target=true, minMode="Leve", stock=3, effect="CreamSplash", description="Creme, PLOFT e reacao; sem tapar toda a tela."},
    {id="banana", name="Casca de Banana", category="Pegadinhas", cost=18, duration=2, disrupt=true, target=false, arena=true, stock=2, effect="BananaSpin", description="Armadilha segura de 2s na Arena da Zoeira."},
    {id="upsideDown", name="Gravidade Maluca", category="Pegadinhas", cost=25, duration=5, disrupt=true, target=true, minMode="Leve", arena=true, stock=1, effect="UpsideDown", description="Giro invertido por 5s na arena."},
    {id="confetti", name="Bomba de Confete", category="Pegadinhas", cost=8, duration=3, disrupt=false, target=true, minMode="Leve", stock=3, effect="Confetti", description="Chuva colorida sem dano."},
    {id="bigHead", name="Cabecao Gigante", category="Pegadinhas", cost=15, duration=6, disrupt=false, target=true, minMode="Leve", effect="BigHead", description="Cabeca gigante temporaria."},
    {id="spaghettiRain", name="Chuva de Espaguete", category="Pegadinhas", cost=12, duration=4, disrupt=false, target=true, minMode="Leve", effect="Spaghetti", description="Massas cartunescas no alto."},
    {id="musicalPot", name="Panela Musical", category="Pegadinhas", cost=10, duration=5, disrupt=false, target=true, minMode="Leve", effect="MusicalPot", description="Notas musicais e panela saltitante."},
    {id="flour", name="Tempestade de Farinha", category="Pegadinhas", cost=12, duration=6, disrupt=false, target=true, minMode="Leve", effect="Flour", description="Nuvem de farinha efemera."},
    {id="ketchup", name="Bigode de Ketchup", category="Pegadinhas", cost=10, duration=8, disrupt=false, target=true, minMode="Leve", effect="Ketchup", description="Bigode vermelho divertido."},
    {id="duck", name="Pato Perseguidor", category="Pegadinhas", cost=15, duration=8, disrupt=false, target=true, minMode="Leve", effect="Duck", description="Mascote visual seguindo o jogador."},
    {id="cheeseRain", name="Chuva de Queijo", category="Pegadinhas", cost=12, duration=5, disrupt=false, target=true, minMode="Leve", effect="Cheese", description="Cubinhos de queijo flutuam."},
    {id="floatingPizza", name="Pizza Voadora", category="Pegadinhas", cost=10, duration=7, disrupt=false, target=true, minMode="Leve", effect="Pizza", description="Pizza gigante giratoria."},
    {id="bubbles", name="Bolhas de Refrigerante", category="Pegadinhas", cost=9, duration=6, disrupt=false, target=true, minMode="Leve", effect="Bubbles", description="Bolhas efervescentes."},
    {id="sadTrombone", name="Trombone Triste", category="Pegadinhas", cost=10, duration=3, disrupt=false, target=true, minMode="Leve", effect="Trombone", description="Trombone faz wa-wa-wa e solta notas."},
    -- Catalogo planejado: propositalmente bloqueado ate existir implementacao individual.
    {id="tinyChef", name="Chef Minusculo"}, {id="chicken", name="Galinha Maluca"},
    {id="crazyDance", name="Danca Maluca"}, {id="sausageSuit", name="Fantasia de Salsicha"},
    {id="wobblyPudding", name="Pudim Tremelicante"}, {id="tallHat", name="Chapeu Infinito"},
    {id="cleaningRobot", name="Robo Faxineiro"}, {id="goat", name="Cabra Barulhenta"},
    {id="vacuum", name="Aspirador Maluco"}, {id="magicPan", name="Frigideira Magica"},
    {id="duckParty", name="Festa dos Patinhos"}, {id="breadRain", name="Chuva de Paes"},
    {id="burgerBalloon", name="Balao de Hamburguer"}, {id="kitchenTrain", name="Trem da Cozinha"},
    {id="ragdoll", name="Modo Boneco de Pano"}, {id="freezerGhost", name="Fantasma do Freezer"},
    {id="panOrchestra", name="Orquestra de Panelas"}, {id="robotChef", name="Chef Robotico"},
    {id="donutBackpack", name="Mochila de Donuts"}
}

local byId = {}
for _, def in ipairs(defs) do
    def.enabled = def.effect ~= nil
    def.category = def.category or "Em breve"
    def.cost = def.cost or 0
    def.stock = def.stock or 0
    def.duration = def.duration or 0
    def.cooldown = def.disrupt and 90 or 8
    byId[def.id] = def
end
return {list=defs, byId=byId, modes={"Tranquilo", "Leve", "Caos"}}
