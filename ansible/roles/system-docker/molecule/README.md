## **Molecule:**

Данная секция предназначена для запуска и выполнения тестов с помощью такого инструмента, как `Molecule`. Этот инструмент осуществляет предварительный запуск ролей на указанных платформах (Docker, Cloud и т.д.). Делается это для того, чтобы когда роль была написана или изменена, не приходилось выполнять её запуск непосредственно на реальных серверах, так как это может привести к непредвиденным обстоятельствам.

### **Установка Molecule:**

Для того чтобы установить `Molecule` локально со всеми зависимостями, выполните следующую команду в корне проекта:

```
pip3 install -r --user requirements.txt
```

### **Запуск тестов в Docker:**

Чтобы запустить полный прогон, необходимо выполнить команду, указав путь к тому или иному виду теста. Так, например, чтобы запустить тесты для данной роли в среде Docker, укажите соответствующий путь, чтобы прогнать роль:

```
molecule test -s [docker-all]
```

В данном случае в директории с именем `docker-all` указан список всех поддерживаемых семейств дистрибутивов Linux для запуска тестов. Отличаются только образы в зависимости от используемого семейства. Конкретно в этой роли это сделано так потому, что сама роль практически не требует никаких ресурсов для запусков. Следовательно нет необходимости разбивать её на семейства в рамках Docker.

### **Запуск тестов в AWS:**

Принцип запуска тестов в AWS придерживается разбиения по семействам. Вот пример запуска тестов для AWS:

```
molecule test -s [aws-debian, aws-ubuntu, aws-suse, aws-redhat] # Укажите на выбор одно из семейств дистрибутивов Linux;
```

Однако перед самим запуском рекомендуется заполнить ряд переменных значениями, выраженных в файле `group_vars` в корне директории `ansible`, которые актуальны для вас: имя профиля, регион в AWS, тип инстанса и т.д. Вот полный список переменных на данный момент:

```
aws_profile: ""
aws_region: ""
aws_instance_type: ""
aws_vpc_subnet_id: ""
aws_vpc_id: ""
aws_key_method: "" 
aws_default_ssh_user: ""
aws_local_private_key: ""
aws_local_public_key: ""
aws_custom_key_name: ""
aws_security_group_name: ""
```

И ещё один аспект. Для каждого семейства дистрибутивов в AWS есть свои версии и реализации. Если по каким-то причинам вас не устраивают предоставленные мною версии дистрибутивов в файле `molecule.yml` для каждого из семейств или вы просто хотите протестировать те же роли на более старых или новых версиях, то в таком случае вы можете воспользоваться списком команд ниже для каждого из семейств. Эти команды выведут информацию в виде таблицы, в которой будет представлен `OwnerID` семейства в AWS, а также полное имя самого образа, которое одинаково вне зависимости от используемого региона, в сравнении с `AMI ID`.

* Для **Ubuntu** это:
```
# Для Ubuntu 20.04
aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
# Для Ubuntu 22.04
aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
# Для Ubuntu 24.04
aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-*-24.04-amd64-server*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
```

* Для **Debian** это:
```
# Для Debian 11
aws ec2 describe-images --owners 136693071363 --filters "Name=name,Values=debian-11-amd64-*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
# Для Debian 12
aws ec2 describe-images --owners 136693071363 --filters "Name=name,Values=debian-12-amd64-*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
# Для Debian 13
aws ec2 describe-images --owners 136693071363 --filters "Name=name,Values=debian-13-amd64-*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
```

* Для **SLES** это:
```
# Для SLEL 15 (можно менять версии SP)
aws ec2 describe-images --owners 013907871322 --filters "Name=name,Values=suse-sles-15-sp5-*-x86_64" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
# Для SLEL 16
aws ec2 describe-images --owners 013907871322 --filters "Name=name,Values=suse-sles-16-*-*-x86_64" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
```

* Для **RedHat** это:
```
# Для RHEL 8
aws ec2 describe-images --owners 309956199498 --filters "Name=name,Values=*RHEL-8.10*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
# Для RHEL 9
aws ec2 describe-images --owners 309956199498 --filters "Name=name,Values=*RHEL-9.5*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
# Для RHEL 10
aws ec2 describe-images --owners 309956199498 --filters "Name=name,Values=*RHEL-10*" --query "Images[*].[OwnerId,CreationDate,Name,ImageId]" --output table
```

### **Прочие команды в Molecule:**

Если вы хотите только подготовить ресурсную базу, без прогона самих ролей, то для этого выполните следующую команду на выбор в зависимости от вашей платформы (в первую очередь актуально для облаков, где мы подготавливаем инфраструктуру):

```
molecule create -s [docker-all] # Укажите на выбор одно из семейств дистрибутивов Linux;
molecule create -s [aws-debian, aws-ubuntu, aws-suse, aws-redhat] # Укажите на выбор одно из семейств дистрибутивов Linux;
```

Если вы хотите запустить прогон тестов для роли без проверки идемпотентности, то для этого выполните следующую команду на выбор в зависимости от вашей платформы:

```
molecule converge -s [docker-all] # Укажите на выбор одно из семейств дистрибутивов Linux;
molecule converge -s [aws-debian, aws-ubuntu, aws-suse, aws-redhat] # Укажите на выбор одно из семейств дистрибутивов Linux;
```

Для проверки идемпотентности запускаемой роли можно использовать следующую команду:

```
molecule idempotence -s [docker-all] # Укажите на выбор одно из семейств дистрибутивов Linux;
molecule idempotence -s [aws-debian, aws-ubuntu, aws-suse, aws-redhat] # Укажите на выбор одно из семейств дистрибутивов Linux;
```

Чтобы явно уничтожить следы деятельности прогона тестов используйте следующую команду:

```
molecule destroy -s [docker-all] # Укажите на выбор одно из семейств дистрибутивов Linux;
molecule destroy -s [aws-debian, aws-ubuntu, aws-suse, aws-redhat] # Укажите на выбор одно из семейств дистрибутивов Linux;
```

Это может быть полезно в некоторых случаях, так как не всегда прогон тестов завершается успешно и иногда кэш или какие-либо другие следы предыдущего запуска могут помешать следующему. Особенно такое поведение можно наблюдать при работе с Docker.
