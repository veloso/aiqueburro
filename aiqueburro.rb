#!ruby19
# encoding: utf8
# author: tiago veloso

require 'rubygems'
require 'twitter'

@config = YAML::load(File.open('/opt/aiqueburro/config.yml')) #abre o config.yml  somente-leitura na memória
@config2 = YAML::load(File.open('/opt/aiqueburro/config_1.yml', 'r+')) #r+ significa leitura e escrita

httpauth = Twitter::HTTPAuth.new(@config['user'], @config['passwd']) #autentica com o Twitter
@aiqueburro = Twitter::Base.new(httpauth) #cria novo objeto da classe Twitter e atribuiu à variável @aiqueburro

def twitta(msg,id)
	if msg.length<=140
		#option = ":in_reply_to_status_id => #{id}" #exemplo de uso de JSON (que não funciona, aliás ;~)
		@aiqueburro.update(msg) #,query={}
		puts msg
	end
end

def atualizabaseusuarios()
  File.open('/opt/aiqueburro/config_1.yml', 'r+') do |file|
    YAML.dump(@config2, file)
  end
  puts "Base atualizada."
end

puts "--"
puts "Início: #{Time.now}"
system "notify-send aiqueburro-inicio"
puts "--"

nvezes = @config['termoerrado'].size #todos os termos
#nvezes = 10 #define quantos termos serão pesquisados, sequencialmente e em ordem decrescente

nvezes.times do
  #numerotermo = rand(@config['termoerrado'].size)+1 # usa os termos aleatoriamente, não sequencialmente
  numerotermo = nvezes #procura por todas os termos, não por um número limitado
  termoerrado = @config['termoerrado'][numerotermo]
  termocerto = @config['termocerto'][numerotermo]

  pesquisa = "\""+termoerrado+"\" -RT -@aiqueburro -formspring.me -from:#{@config['user']}"

  ultimousuario = @config2['ultimo'][numerotermo]

  quantostweets = 10

  mensagens = Twitter::Search.new(pesquisa).since(ultimousuario).per_page(quantostweets) #per_page() - até quantas correções (tweets enviados) ele vai fazer pra cada termo
  
  puts "Pesquisando por \"#{termoerrado}\"..."
  puts "O último a dizer foi #{ultimousuario}"

  xvezes=0 #POG

  mensagens.each do |msg|
    #if msg.from_user == ultimousuario then break end # para a iteração quando alcança o usuário já corrigido
      frase = @config['frase'][rand(@config['frase'].size)+1]
      #@usuario = msg.from_user
      id = msg.id # pegar o id do tweet
      puts "id = #{id}"
      msg = ("@#{msg.from_user} \"#{termoerrado}\"?! #{frase} O certo é: #{termocerto}!")
      twitta(msg,id)
      #begin POG
      puts "xvezes antes = #{xvezes}"
      if xvezes==0 then @config2['ultimo'][numerotermo] = id end #define que o usuário que ele passou foi o último
      xvezes+=1
      puts "xvezes depois = #{xvezes}"
      # end POG
      atualizabaseusuarios()
    end
  nvezes-=1
  puts "nvezes = #{nvezes}"
  puts "--"
end

atualizabaseusuarios()

puts "Fim: #{Time.now}"
system "notify-send aiqueburro-fim"
