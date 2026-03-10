# **Модуль: auth_jwt**

**Модуль auth_jwt** – включает метод аутентификации JWT в Vault и создаёт роль для проверки токенов от внешних провайдеров идентичности. Предназначен в первую очередь для аутентификации CI/CD пайплайнов (GitHub Actions, GitLab CI) и внешних сервисов без использования статичных учётных данных. Vault самостоятельно верифицирует подпись JWT через JWKS endpoint провайдера.

---

## **Как работает**

В отличие от AppRole, при использовании JWT метода статичных секретов нет вообще. Внешний провайдер (GitHub, GitLab) автоматически выдаёт JWT токен в контексте каждого задания или пайплайна. Этот токен содержит claims с информацией о контексте запуска: имя репозитория, ветка, окружение, имя workflow. Vault получает токен, запрашивает публичные ключи провайдера через `jwks_url`, проверяет подпись и сравнивает claims с ограничениями, настроенными в роли через `bound_claims`. Если все проверки пройдены – выдаётся Vault-токен с указанными политиками.

`bound_claims` является ключевым механизмом безопасности: каждый claim из этого параметра должен точно совпасть со значением в предъявленном JWT. Если хотя бы один claim не совпадает – Vault возвращает ошибку `403`.

Для CI/CD рекомендуется использовать `batch` тип токена: он не хранится в Vault storage, не требует продления и автоматически истекает по TTL вместе с завершением задания. Один Vault может обслуживать несколько провайдеров одновременно – для каждого создаётся отдельный экземпляр модуля с уникальным значением `path`.

---

## **Параметры модуля**

### Backend

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `path` | `string` | `"jwt"` | Путь монтирования JWT auth backend |
| `description` | `string` | `""` | Описание backend |
| `jwks_url` | `string` | – | URL для получения JWKS (публичных ключей провайдера) (обязательный) |
| `jwks_ca_pem` | `string` | `""` | PEM CA сертификат для JWKS URL. Пусто = использовать системный CA |
| `bound_issuer` | `string` | `""` | Ожидаемое значение claim `iss`. Пусто = без ограничений |

### Роль

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `role_name` | `string` | – | Имя роли (обязательный) |
| `role_type` | `string` | `"jwt"` | Тип роли: `jwt` или `oidc` |
| `user_claim` | `string` | `"sub"` | Claim JWT, который маппится в username Vault |
| `bound_audiences` | `list(string)` | `[]` | Допустимые значения claim `aud`. Пусто = без ограничений |
| `bound_subject` | `string` | `""` | Ожидаемое значение claim `sub`. Пусто = без ограничений |
| `bound_claims` | `map(string)` | `{}` | Дополнительные ограничения по claim-ам JWT |
| `token_policies` | `list(string)` | – | Политики Vault для выдаваемых токенов (обязательный) |
| `token_ttl` | `number` | `3600` | TTL токена в секундах |
| `token_max_ttl` | `number` | `86400` | Максимальный TTL токена в секундах |
| `token_num_uses` | `number` | `0` | Число использований токена. 0 = без ограничений |
| `token_type` | `string` | `"default"` | Тип токена: `default`, `service`, `batch` |
| `token_bound_cidrs` | `list(string)` | `[]` | CIDR ограничения для токена |

---

## **Примеры вызова модуля**

### Простой вариант: GitHub Actions

Минимальный пример для аутентификации GitHub Actions пайплайна:

```hcl
module "auth_jwt_github" {
  source = "../../../modules/auth_jwt"

  path         = "jwt"
  jwks_url     = "https://token.actions.githubusercontent.com/.well-known/jwks"
  bound_issuer = "https://token.actions.githubusercontent.com"

  role_name       = "github-actions"
  bound_audiences = ["https://github.com/my-org"]
  bound_claims    = { repository = "my-org/my-repo" }
  user_claim      = "sub"

  token_policies = ["cicd-policy"]
  token_ttl      = 300
  token_type     = "batch"
}
```

---

### Полный вариант: связка с модулем vault_custom_policy

Рекомендуемый подход – политика создаётся отдельным модулем и передаётся через output:

```hcl
module "policy_cicd" {
  source = "../../../modules/vault_custom_policy"

  name = "cicd-policy"
  rules = [
    { path = "secret/data/cicd/*",     capabilities = ["read"] },
    { path = "secret/metadata/cicd/*", capabilities = ["list"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
  ]
}

module "auth_jwt_github" {
  source = "../../../modules/auth_jwt"

  path         = "jwt"
  jwks_url     = "https://token.actions.githubusercontent.com/.well-known/jwks"
  bound_issuer = "https://token.actions.githubusercontent.com"

  role_name       = "github-actions"
  bound_audiences = ["https://github.com/my-org"]
  bound_claims    = {
    repository  = "my-org/my-repo"
    ref         = "refs/heads/main"
    environment = "production"
  }
  user_claim = "sub"

  token_policies = [module.policy_cicd.policy_name]
  token_ttl      = 300
  token_max_ttl  = 300
  token_type     = "batch"
}
```

---

### Вариант для GitLab CI

```hcl
module "auth_jwt_gitlab" {
  source = "../../../modules/auth_jwt"

  path         = "jwt-gitlab"
  jwks_url     = "https://gitlab.com/-/jwks"
  bound_issuer = "https://gitlab.com"

  role_name       = "gitlab-ci"
  bound_audiences = ["https://gitlab.com"]
  bound_claims    = { namespace_path = "my-group/my-project" }
  user_claim      = "sub"

  token_policies = [module.policy_cicd.policy_name]
  token_ttl      = 300
  token_type     = "batch"
}
```

GitLab CI предоставляет JWT автоматически через переменную окружения `CI_JOB_JWT_V2` в контексте каждого задания.

---

## **Параметры bound_claims для GitHub Actions**

`bound_claims` является основным механизмом ограничения доступа. Vault проверяет каждый указанный claim в предъявленном JWT. Если хотя бы один не совпадает – логин отклоняется.

| Claim | Пример значения | Что ограничивает |
|---|---|---|
| `repository` | `"my-org/my-repo"` | Конкретный репозиторий |
| `repository_owner` | `"my-org"` | Все репозитории организации |
| `ref` | `"refs/heads/main"` | Только ветку `main` |
| `environment` | `"production"` | Только jobs с указанным environment |
| `job_workflow_ref` | `"my-org/my-repo/.github/workflows/deploy.yml@refs/heads/main"` | Конкретный workflow файл |

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `mount_path` | `string` | Путь монтирования JWT auth backend |
| `role_name` | `string` | Имя созданной роли |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output mount_path
terragrunt output role_name
```

---

## **После apply**

После успешного применения конфигурации проверить состояние JWT auth backend можно с помощью следующих команд:

```bash
# Список включённых auth backends
vault auth list

# Проверить конфигурацию backend
vault read auth/jwt

# Проверить конфигурацию роли
vault read auth/jwt/role/github-actions
```

Пример шага в GitHub Actions workflow для получения Vault токена:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write   # обязательно – разрешает получение JWT от GitHub
      contents: read

    steps:
      - name: Authenticate to Vault
        env:
          VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
        run: |
          JWT=$(curl -sS \
            -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
            -H "Accept: application/json" \
            "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=https://github.com/my-org" \
            | jq -r '.value')

          VAULT_TOKEN=$(curl -sS -X POST "$VAULT_ADDR/v1/auth/jwt/login" \
            -H "Content-Type: application/json" \
            -d "{\"role\": \"github-actions\", \"jwt\": \"$JWT\"}" \
            | jq -r '.auth.client_token')

          echo "::add-mask::$VAULT_TOKEN"
          echo "VAULT_TOKEN=$VAULT_TOKEN" >> $GITHUB_ENV
```

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
