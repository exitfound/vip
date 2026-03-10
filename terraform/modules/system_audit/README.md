# **Модуль: system_audit**

**Модуль system_audit** – предназначен для включения и настройки Audit Devices в Vault. Vault записывает все входящие запросы и исходящие ответы в audit log, что является обязательным условием для обеспечения прослеживаемости и аудита в Production-среде. Модуль поддерживает два типа устройств: `file` (запись в файл на диске) и `syslog` (передача в системный журнал).

---

## **Как работает**

Vault пишет все запросы и ответы в audit log вне зависимости от их результата. Это означает, что каждое обращение к Vault – будь то получение секрета, аутентификация или изменение политики – фиксируется в журнале. Если хотя бы один включённый Audit Device становится недоступным, Vault переходит в режим **fail-closed** и начинает отклонять любые запросы до тех пор, пока устройство не станет снова доступным. Это принципиальное поведение: нельзя взаимодействовать с Vault, не оставив след.

Чувствительные данные – токены, ключи, значения секретов – в логах по умолчанию **не фигурируют в открытом виде**: accessor токена хешируется через HMAC (`hmac_accessor = true`), а само значение `log_raw` по умолчанию отключено. Включать `log_raw` допустимо исключительно в отладочных целях и никогда в Production.

Модуль содержит два ресурса под флагами – `vault_audit.file` и `vault_audit.syslog`. Vault не позволяет зарегистрировать два устройства одного типа на одном и том же пути, поэтому если требуется включить оба типа одновременно, необходимо создать два отдельных экземпляра модуля: один включает `file`, другой – `syslog`.

---

## **Параметры модуля**

Ниже представлены все переменные модуля и их назначение:

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `enable_file` | `bool` | `true` | Включить file audit device |
| `file_path` | `string` | `"/var/log/vault/audit.log"` | Путь к файлу на диске, куда Vault пишет записи аудита |
| `file_mode` | `string` | `"0600"` | Права на файл в восьмеричном формате |
| `enable_syslog` | `bool` | `false` | Включить syslog audit device |
| `syslog_facility` | `string` | `"AUTH"` | Syslog facility (только при `enable_syslog = true`) |
| `syslog_tag` | `string` | `"vault"` | Syslog tag (только при `enable_syslog = true`) |
| `log_raw` | `bool` | `false` | Писать чувствительные данные в открытом виде – исключительно для отладки, никогда в Production |
| `hmac_accessor` | `bool` | `true` | Хешировать accessor токена в записях аудита |
| `format` | `string` | `"json"` | Формат записей аудита: `json` или `jsonx` |

---

## **Режимы работы**

Модуль поддерживает **3 режима работы**, которые определяются комбинацией переменных `enable_file` и `enable_syslog`:

```hcl
# Режим 1: Только file audit device (по умолчанию)
enable_file   = true
enable_syslog = false

# Режим 2: Только syslog audit device
enable_file   = true
enable_syslog = false

# Режим 3: Оба типа одновременно
# Vault запрещает регистрировать два устройства одного типа на одном пути,
# поэтому оба типа включаются через два отдельных экземпляра модуля.
# Первый экземпляр:
enable_file   = true
enable_syslog = false
# Второй экземпляр:
enable_file   = false
enable_syslog = true
```

---

## **Примеры вызова модуля**

### Простой вариант: только file

Минимальный пример для включения записи аудита в файл:

```hcl
module "audit_file" {
  source = "../../../modules/system_audit"

  enable_file   = true
  enable_syslog = false
  file_path     = "/var/log/vault/audit.log"
  file_mode     = "0600"
}
```

---

### Простой вариант: только syslog

Минимальный пример для передачи аудита в системный журнал:

```hcl
module "audit_syslog" {
  source = "../../../modules/system_audit"

  enable_file     = false
  enable_syslog   = true
  syslog_facility = "AUTH"
  syslog_tag      = "vault"
}
```

---

### Полный вариант: оба типа одновременно

Два отдельных экземпляра модуля для одновременного включения `file` и `syslog`:

```hcl
module "audit_file" {
  source = "../../../modules/system_audit"

  enable_file   = true
  enable_syslog = false
  file_path     = "/var/log/vault/audit.log"
  file_mode     = "0600"
  log_raw       = false
  hmac_accessor = true
  format        = "json"
}

module "audit_syslog" {
  source = "../../../modules/system_audit"

  enable_file     = false
  enable_syslog   = true
  syslog_facility = "AUTH"
  syslog_tag      = "vault"
  log_raw         = false
  hmac_accessor   = true
  format          = "json"
}
```

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `file_audit_path` | `string` | Путь Vault-ресурса для file audit device (`null`, если отключён) |
| `syslog_audit_path` | `string` | Путь Vault-ресурса для syslog audit device (`null`, если отключён) |
| `enabled_devices` | `list(string)` | Список включённых типов устройств аудита |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output -json enabled_devices
terragrunt output file_audit_path
terragrunt output syslog_audit_path
```

---

## **После apply**

После успешного применения конфигурации проверить состояние Audit Devices можно с помощью следующих команд:

```bash
# Проверить список включённых audit devices
vault audit list -detailed

# Убедиться что file device создаёт записи
tail -f /var/log/vault/audit.log

# Убедиться что syslog device передаёт события в системный журнал
journalctl -t vault -f
```

---

## **Важно**

Перед применением модуля необходимо убедиться, что директория для `file_path` существует и доступна пользователю `vault`. Если директории нет, Vault не сможет создать файл аудита и завершит регистрацию устройства с ошибкой:

```bash
mkdir -p /var/log/vault && chown vault:vault /var/log/vault
```

Vault рекомендуется использовать хотя бы один рабочий Audit Device перед отзывом root-токена. Если все зарегистрированные устройства аудита становятся недоступными одновременно – Vault переходит в режим **fail-closed** и перестаёт обрабатывать любые запросы.

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
