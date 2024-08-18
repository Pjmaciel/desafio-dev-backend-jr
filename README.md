
# Desafio Dev Backend Jr - Pablo Jorge Maciel

[![Ruby](https://img.shields.io/badge/Ruby-3.3.0-red)](https://www.ruby-lang.org/en/)
[![Rails](https://img.shields.io/badge/Rails-7.1.3.4-red)](https://rubyonrails.org/)
[![Linux Mint](https://img.shields.io/badge/Linux_Mint-21.3_Cinnamon-green)](https://linuxmint.com/)
[![RubyMine](https://img.shields.io/badge/RubyMine-2024.2-orange)](https://www.jetbrains.com/ruby/)

## 📘 Descrição do Projeto

Este projeto foi desenvolvido como parte do processo seletivo para a posição de Desenvolvedor Backend Jr. A aplicação consiste em uma plataforma robusta para processamento de arquivos XML de notas fiscais eletrônicas (NFe). Construída com Ruby on Rails, a aplicação permite que os usuários façam upload de arquivos XML, que são processados em background utilizando Sidekiq, e fornece relatórios detalhados com informações extraídas dos documentos.

## ⚙️ Requisitos Funcionais

- **Autenticação de Usuário**: Implementação de um sistema de login seguro utilizando Devise.
- **Upload de Documentos**: Interface amigável para upload de arquivos XML.
- **Processamento em Background**: Utilização do Sidekiq para processamento assíncrono dos arquivos XML.
- **Relatório**: Geração de relatórios detalhados com dados extraídos dos XMLs processados.
- **Filtros**: Filtros avançados para facilitar a busca e visualização dos relatórios.
- **Testes Automatizados**: Implementação de testes robustos usando RSpec.
- **Processamento em Lote**: Suporte para upload e processamento de múltiplos arquivos XML dentro de um arquivo ZIP.
- **Exportação de Relatório**: Possibilidade de exportar os relatórios gerados em formato Excel.

## 🛠️ Tecnologias Utilizadas

- **Ruby**: 3.3.0
- **Rails**: 7.1.3.4
- **Sidekiq**: Processamento em background.
- **RSpec**: Testes automatizados.
- **Active Storage**: Gerenciamento de upload de arquivos.
- **Devise**: Autenticação de usuários.
- **PostgreSQL**: Banco de dados relacional.

## 🚀 Instalação

### Pré-requisitos

- **Ruby 3.3.0** e **Rails 7.1.3.4** instalados.
- **PostgreSQL** configurado e em execução.
- **Redis** para suporte ao Sidekiq.

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/seu-repositorio.git
   cd seu-repositorio
   ```

2. **Instale as dependências:**
   ```bash
   bundle install
   yarn install
   ```

3. **Configure o banco de dados:**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Inicie o Redis e o Sidekiq:**
   ```bash
   redis-server &
   bundle exec sidekiq
   ```

5. **Inicie o servidor Rails:**
   ```bash
   rails server
   ```

6. **Acesse a aplicação em** `http://localhost:3000`.

## 📝 Uso

1. **Registro e Login:** Crie uma conta ou faça login para acessar a plataforma.
2. **Upload de Arquivos:** Navegue até a seção de upload, selecione e envie arquivos XML ou um arquivo ZIP contendo múltiplos XMLs.
3. **Processamento e Relatórios:** Acompanhe o processamento dos arquivos em background e acesse os relatórios gerados. Utilize os filtros para buscar informações específicas.
4. **Exportação:** Exporte os relatórios em formato Excel conforme necessário.

## ✅ Testes

Para executar os testes automatizados, utilize o seguinte comando:
```bash
bundle exec rspec
```

## 📦 Deploy

A aplicação está implantada na plataforma Fly.io. Para acessar a aplicação online, clique no link a seguir:

[https://desafio-dev-backend-jr.fly.dev/](https://desafio-dev-backend-jr.fly.dev/)


## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests. Segue abaixo as orientações para contribuir com o projeto:

1. Fork o repositório.
2. Crie uma branch para a nova feature (`git checkout -b feature/nova-feature`).
3. Faça o commit das suas mudanças (`git commit -m 'Adiciona nova feature'`).
4. Envie para o repositório remoto (`git push origin feature/nova-feature`).
5. Abra um Pull Request.

## 🛡️ Licença

Este projeto é licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📧 Contato

[LinkedIn](https://www.linkedin.com/in/seu-perfil)

[Wakatime](https://wakatime.com/@pjmaciel)

---