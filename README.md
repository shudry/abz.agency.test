# Це тестовий проект для abz.agency на позицію Junior Python Developer

## Виконайте:
```bash 
$ mkdir shudry-test-project && cd shudry-test-project 
```

## Налаштування MySQL
```bash
$ sudo apt install mysql-server mysql-client libmysqlclient-dev
$ mysql -u root -p
```
```sql 
CREATE DATABASE abzagencydatabase DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE USER "django"@"localhost" IDENTIFIED BY "password";
GRANT ALL PRIVILEGES ON abzagencydatabase.* TO "django"@"localhost";
FLUSH PRIVILEGES; 
```

## Віртуальне оточення (Python >=3.5)
```bash
$ virtualenv --no-site-packages -p python3.5 .virtual && source .virtual/bin/activate 
```

## Налаштування проекту:
```bash
$ git clone https://github.com/shudry/abz.agency.test.git && cd abz.agency.test
$ pip install -r requirements.txt 
```

```bash
$ ./manage.py makemigrations && ./manage.py migrate 
$ ./manage.py collectstatic 
```
Також створіть адміністратора:
```bash
$ ./manage.py createsuperuser 
```

## Заповнення бази рандомними данними:
```bash
$ ./manage.py seed_workers -w 100 200 300 400 500
```
**-w [кількість працівників]** потрібно передати 5 значень. Якщо менше або більше(**-w 10 20 30**) буде створенна структура з відповідною кількістю працівників в ієрархії за замовчуванням: **-w 1 2 3 4 5**(15 працівників)

Якщо потрібно видалити усіх працівників: 
```bash
$ ./manage.py remove_workers 
```

## І наостанок:
```bash
$ ./manage.py runserver 
```