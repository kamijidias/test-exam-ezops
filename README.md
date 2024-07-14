# Teste-Ezops

Este repositório contém a estrutura do projeto com configuração de CI/CD com GitHub Actions, implantação de backend e frontend, e infraestrutura como código com Terraform e Kubernetes.

## Estrutura do Projeto

- **.github/workflows**
  - `Backend-deploy.yml`: Workflow para implantação do backend.
  - `Frontend-deploy.yml`: Workflow para implantação do frontend.

- **kubernetes**
  - `backend-deploy.yaml`: Configuração de deployment do backend no Kubernetes.
  - `backend-service.yaml`: Configuração de service do backend no Kubernetes.
  - `master-setup.sh`: Script de setup do master node.
  - `postgres-cmap.yaml`: Configuração do ConfigMap do PostgreSQL.
  - `postgres-deploy.yaml`: Configuração de deployment do PostgreSQL.
  - `postgres-service.yaml`: Configuração de service do PostgreSQL.
  - `psql-claim.yaml`: Configuração de PersistentVolumeClaim do PostgreSQL.
  - `psql-pv.yaml`: Configuração de PersistentVolume do PostgreSQL.
  - `worker-setup.sh`: Script de setup do worker node.

- **rest-api-ezops-test**
  - `database/`: Diretório contendo arquivos relacionados ao banco de dados.
  - `server/`: Diretório contendo a aplicação backend.
    - `.env`: Arquivo de variáveis de ambiente.
    - `.gitignore`: Arquivo de configuração para ignorar arquivos no git.
    - `Dockerfile`: Dockerfile para a aplicação backend.
    - `package-lock.json`: Arquivo de lock do npm.
    - `package.json`: Arquivo de configuração do npm.
    - `README.md`: Documentação da aplicação backend.
    - `request_response.txt`: Exemplo de request e response.
    - `status_code.txt`: Documentação dos códigos de status.

- **terraform**
  - `.terraform/`: Diretório contendo arquivos internos do Terraform.
  - `.gitignore`: Arquivo de configuração para ignorar arquivos no git.
  - `terraform.lock.hcl`: Arquivo de lock do Terraform.
  - `ec2.tf`: Configuração de instâncias EC2.
  - `main.tf`: Configuração principal do Terraform.
  - `outputs.tf`: Configuração de outputs do Terraform.
  - `s3-cloudfront.tf`: Configuração do S3 e CloudFront.
  - `security_groups.tf`: Configuração dos security groups.
  - `terraform.tfstate`: Arquivo de estado do Terraform.
  - `terraform.tfstate.backup`: Backup do arquivo de estado do Terraform.
  - `terraform.tfvars`: Variáveis do Terraform.
  - `variables.tf`: Definição de variáveis do Terraform.

- **vuejs-ezops-test**
  - `public/`: Diretório público da aplicação frontend.
  - `src/`: Diretório fonte da aplicação frontend.
    - `.browserslistrc`: Configuração de compatibilidade de navegadores.
    - `.editorconfig`: Configuração do editor.
    - `.eslintrc.js`: Configuração do ESLint.
    - `.gitignore`: Arquivo de configuração para ignorar arquivos no git.
    - `babel.config.js`: Configuração do Babel.
    - `Dockerfile`: Dockerfile para a aplicação frontend.
    - `LICENSE`: Licença do projeto.
    - `package-lock.json`: Arquivo de lock do npm.
    - `package.json`: Arquivo de configuração do npm.
    - `postcss.config.js`: Configuração do PostCSS.
    - `README.md`: Documentação da aplicação frontend.
    - `vue.config.js`: Configuração do Vue.
    - `webpack.config.js`: Configuração do Webpack.
  - `.gitignore`: Arquivo de configuração para ignorar arquivos no git.
  - `docker-compose.yml`: Arquivo de configuração do Docker Compose.
  - `README.md`: Documentação do projeto.

## Passos para Implantação

### Backend

1. **Configuração do Docker**
   - Certifique-se de ter o Docker instalado e funcionando corretamente.
   - Construa a imagem Docker para o backend:
     ```sh
     docker build -t backend-ezops-test ./rest-api-ezops-test/server
     ```
   - Inicie o container Docker:
     ```sh
     docker run -d -p 3000:3000 backend-ezops-test
     ```

2. **Implantação com Kubernetes**
   - Configure seu cluster Kubernetes.
   - Aplique as configurações do backend:
     ```sh
     kubectl apply -f kubernetes/backend-deploy.yaml
     kubectl apply -f kubernetes/backend-service.yaml
     ```

3. **Workflows do GitHub Actions**
   - Verifique e configure os workflows em `.github/workflows/Backend-deploy.yml`.

### Frontend

1. **Configuração do Docker**
   - Certifique-se de ter o Docker instalado e funcionando corretamente.
   - Construa a imagem Docker para o frontend:
     ```sh
     docker build -t frontend-ezops-test ./vuejs-ezops-test
     ```
   - Inicie o container Docker:
     ```sh
     docker run -d -p 8080:80 frontend-ezops-test
     ```

2. **Implantação com Kubernetes**
   - Configure seu cluster Kubernetes.
   - Aplique as configurações do frontend (crie os arquivos necessários como deployments e services se não existirem).

3. **Workflows do GitHub Actions**
   - Verifique e configure os workflows em `.github/workflows/Frontend-deploy.yml`.

### Infraestrutura com Terraform

1. **Configuração Inicial**
   - Certifique-se de ter o Terraform instalado e configurado.
   - Inicialize o Terraform:
     ```sh
     terraform init ./terraform
     ```

2. **Planejamento das Configurações**
   - Verifique o plano de execução para garantir que as mudanças são as esperadas:
     ```sh
     terraform plan ./terraform
     ```

3. **Aplicação das Configurações**
   - Aplique as configurações:
     ```sh
     terraform apply ./terraform
     ```