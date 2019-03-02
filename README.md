## Це тестовий проект для **abz.agency** на позицію Junior Python Developer

### Виконайте:
``` mkdir shudry-test-project && cd shudry-test-project ```

### Налаштування MySQL
``` sudo apt install mysql-server mysql-client libmysqlclient-dev ```
``` mysql -u root -p ```
``` mysql> CREATE DATABASE abzagencydatabase DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;```
``` mysql> CREATE USER "django"@"localhost" IDENTIFIED BY "password"; ```
``` mysql> GRANT ALL PRIVILEGES ON abzagencydatabase.* TO "django"@"localhost"; ```
``` mysql> FLUSH PRIVILEGES; ```

### Віртуальне оточення (Python >=3.5)
``` virtualenv --no-site-packages -p python3.5 .virtual && source .virtual/bin/activate ```

### Налаштування проекту:
``` git clone https://github.com/shudry/shudry-test-project.git && cd shudry-test-project ```
``` pip install -r requirements.txt ```

``` ./manage.py makemigrations && ./manage.py migrate ```
``` ./manage.py collectstatic ```
Також створіть адміністратора:
``` ./manage.py createsuperuser ```

### Заповнення бази рандомними данними:
``` ./manage.py seed_workers -w 100 200 300 400 500 ```
**-w [кількість працівників]** потрібно передати 5 значень. Якщо менше або більше(**-w 10 20 30**) буде створенна структура з відповідною кількістю працівників в ієрархії за замовчуванням: **-w 1 2 3 4 5**(15 працівників)

Якщо потрібно видалити усіх працівників:
``` ./manage.py remove_workers ```