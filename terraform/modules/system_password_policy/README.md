# **Модуль: system_password_policy**

**Модуль system_password_policy** – создаёт Password Policy в Vault, описывающую правила генерации паролей: общую длину и минимальное количество символов из каждого набора (строчные, прописные, цифры, спецсимволы). Vault использует политику при генерации паролей на стороне сервера через API, что является ключевым преимуществом: сгенерированный пароль **не попадает в Terraform state**.

---

## **Как работает**

Password Policy описывает требования к паролям в виде набора правил `charset` + `min_chars`. После применения модуля в Vault появляется политика, которую можно использовать для генерации пароля через команду `vault read sys/policies/password/<name>/generate`. Vault генерирует случайный пароль, удовлетворяющий всем правилам, и возвращает его. Сам пароль нигде не сохраняется.

Это принципиально отличает данный подход от использования ресурса `random_password` в Terraform, значение которого хранится в state и может быть скомпрометировано. В рамках этого проекта Password Policy используется совместно с модулем `auth_userpass` для генерации начальных паролей пользователей.

---

## **Параметры модуля**

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `name` | `string` | – | Имя политики (обязательный) |
| `length` | `number` | `20` | Длина генерируемого пароля |
| `rules` | `list(object)` | `[lowercase, uppercase, digits]` | Список правил: `charset` = набор символов, `min_chars` = минимальное количество символов из этого набора |

### Структура объекта в переменной `rules`

| Поле | Тип | Описание |
|---|---|---|
| `charset` | `string` | Строка с допустимыми символами |
| `min_chars` | `number` | Минимальное количество символов из этого набора в итоговом пароле |

---

## **Примеры вызова модуля**

### Простой вариант: только буквы и цифры

Минимальная политика без спецсимволов, подходит для сервисных аккаунтов или систем с ограничениями на спецсимволы:

```hcl
module "password_policy_simple" {
  source = "../../../modules/system_password_policy"

  name   = "simple-password"
  length = 16

  rules = [
    { charset = "abcdefghijklmnopqrstuvwxyz", min_chars = 1 },
    { charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", min_chars = 1 },
    { charset = "0123456789",                 min_chars = 1 },
  ]
}
```

---

### Полный вариант: политика для операторов со спецсимволами

Более строгая политика для интерактивных пользователей с требованием спецсимволов:

```hcl
module "password_policy_ops" {
  source = "../../../modules/system_password_policy"

  name   = "ops-password"
  length = 24

  rules = [
    { charset = "abcdefghijklmnopqrstuvwxyz", min_chars = 2 },
    { charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", min_chars = 2 },
    { charset = "0123456789",                 min_chars = 2 },
    { charset = "!@#$%&*",                    min_chars = 1 },
  ]
}
```

---

### Вариант для сервисных аккаунтов: длинный, без спецсимволов

Политика для токенов и ключей, которые используются в конфигурационных файлах и переменных окружения:

```hcl
module "password_policy_service" {
  source = "../../../modules/system_password_policy"

  name   = "service-password"
  length = 32

  rules = [
    { charset = "abcdefghijklmnopqrstuvwxyz", min_chars = 1 },
    { charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", min_chars = 1 },
    { charset = "0123456789",                 min_chars = 1 },
  ]
}
```

---

## **Итоговый HCL в Vault**

Для примера с `password_policy_ops` модуль сгенерирует и применит следующую конфигурацию:

```hcl
length = 24

rule "charset" {
  charset   = "abcdefghijklmnopqrstuvwxyz"
  min-chars = 2
}

rule "charset" {
  charset   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  min-chars = 2
}

rule "charset" {
  charset   = "0123456789"
  min-chars = 2
}

rule "charset" {
  charset   = "!@#$%&*"
  min-chars = 1
}
```

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующее выходное значение:

| Output | Тип | Описание |
|---|---|---|
| `policy_name` | `string` | Имя созданной password policy |

Запросить значение output можно с помощью следующей команды:

```bash
terragrunt output policy_name
```

---

## **После apply**

После успешного применения конфигурации можно сгенерировать пароль и управлять политиками с помощью следующих команд:

```bash
# Сгенерировать пароль по политике
vault read sys/policies/password/ops-password/generate

# Получить только значение пароля
vault read -field=password sys/policies/password/ops-password/generate

# Список всех password policies
vault list sys/policies/password

# Посмотреть правила политики
vault read sys/policies/password/ops-password

# Сменить пароль userpass-пользователя с помощью политики
NEW_PASS=$(vault read -field=password sys/policies/password/ops-password/generate)
vault write auth/userpass/users/alice password="$NEW_PASS"
```

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
