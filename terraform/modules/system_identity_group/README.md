# **Модуль: system_identity_group**

**Модуль system_identity_group** – создаёт Identity Group в Vault и управляет её членством. Группа объединяет несколько entities и применяет к ним общие политики. Поддерживает два типа: `internal` (членство управляется явно через Terraform) и `external` (членство синхронизируется автоматически из внешней системы – LDAP, OIDC, GitHub).

---

## **Как работает**

Политики группы наследуются всеми её членами – entity может состоять в нескольких группах и получать права из каждой. Группы поддерживают вложенность: через `member_group_ids` одна группа может включать в себя другие, выстраивая иерархию.

**Internal группа** – члены прописываются явно через `member_entity_ids` и `member_group_ids`. Используется для небольших известных наборов пользователей: команда ops, разработчики конкретного сервиса.

**External группа** – Vault автоматически синхронизирует членство из внешней системы через group alias. Например, если пользователь входит в LDAP-группу `CN=ops` – Vault автоматически добавит его entity в соответствующую Vault-группу при каждом логине. Для external группы `member_entity_ids` и `member_group_ids` не используются – состав определяется внешней системой.

В данном проекте политики рекомендуется назначать через auth-методы (`token_policies` в AppRole/Userpass), а не через группы напрямую – это более предсказуемо при изменениях. Группы используются для организационной структуры и metadata.

---

## **Параметры модуля**

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `name` | `string` | – | Имя группы (обязательный) |
| `type` | `string` | `"internal"` | Тип группы: `internal` или `external` |
| `policies` | `list(string)` | `[]` | Политики группы – наследуются всеми членами |
| `metadata` | `map(string)` | `{}` | Метаданные группы |
| `member_entity_ids` | `list(string)` | `[]` | ID entity-членов (только для `internal`) |
| `member_group_ids` | `list(string)` | `[]` | ID дочерних групп (только для `internal`) |
| `alias_name` | `string` | `""` | Имя группы во внешней системе (только для `external`) |
| `alias_mount_accessor` | `string` | `""` | Accessor auth backend (только для `external`) |

---

## **Примеры вызова модуля**

### Простой вариант: internal группа без политик

Минимальный пример – группа для организации пользователей, политики назначаются на auth-методах:

```hcl
module "group_ops" {
  source = "../../../modules/system_identity_group"

  name              = "ops-team"
  type              = "internal"
  policies          = []
  member_entity_ids = [module.entity_alice.entity_id, module.entity_bob.entity_id]
  metadata          = { team = "ops" }
}
```

Политики назначаются через `token_policies` в auth-методе (Userpass/AppRole), а не через группу. Это позволяет менять права независимо от состава группы.

---

### Полный вариант: internal группа с политиками на группе

```hcl
module "policy_ops" {
  source = "../../../modules/vault_custom_policy"

  name = "ops-policy"
  rules = [
    { path = "secret/data/ops/*",      capabilities = ["read", "list"] },
    { path = "secret/metadata/ops/*",  capabilities = ["list"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
    { path = "auth/token/renew-self",  capabilities = ["update"] },
  ]
}

module "group_ops" {
  source = "../../../modules/system_identity_group"

  name              = "ops-team"
  type              = "internal"
  policies          = [module.policy_ops.policy_name]
  member_entity_ids = [module.entity_alice.entity_id, module.entity_bob.entity_id]
  metadata          = { team = "ops" }
}
```

---

### Вариант: иерархия групп

Родительская группа включает в себя дочерние – политики родителя наследуются всеми членами дочерних групп:

```hcl
module "group_platform" {
  source = "../../../modules/system_identity_group"

  name             = "platform"
  type             = "internal"
  policies         = []
  member_group_ids = [module.group_ops.group_id, module.group_dev.group_id]
}
```

---

### Вариант: external группа (LDAP)

```hcl
data "vault_auth_backend" "ldap" {
  path = "ldap"
}

module "group_ldap_ops" {
  source = "../../../modules/system_identity_group"

  name                 = "ldap-ops"
  type                 = "external"
  policies             = ["ops-policy"]
  alias_name           = "CN=ops,OU=groups,DC=example,DC=com"
  alias_mount_accessor = data.vault_auth_backend.ldap.accessor
}
```

При логине через LDAP Vault проверяет членство пользователя в LDAP-группе и автоматически добавляет его entity в эту Vault-группу.

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `group_id` | `string` | ID созданной группы – передаётся в `member_group_ids` родительских групп |
| `group_name` | `string` | Имя группы |
| `alias_id` | `string` | ID group alias – только для external групп. `null` для internal |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output group_id
terragrunt output group_name
terragrunt output alias_id   # только для external групп
```

---

## **После apply**

После успешного применения конфигурации проверить состояние группы можно с помощью следующих команд:

```bash
# Посмотреть группу по имени
vault read identity/group/name/ops-team

# Список всех групп
vault list identity/group/name

# Проверить членов группы (поле member_entity_ids)
vault read identity/group/name/ops-team

# Добавить entity в группу вручную (без Terraform)
vault write identity/group/name/ops-team \
  member_entity_ids="<id1>,<id2>"

# Проверить в каких группах состоит entity (поля direct_group_ids, inherited_group_ids)
vault read identity/entity/name/alice
```

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
