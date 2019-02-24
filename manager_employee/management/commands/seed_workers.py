import random

from django.core.management.base import BaseCommand
from faker import Faker

from manager_employee.models import Employee


class Command(BaseCommand):
    
    help = "Filling employee base with random values"

    def handle(self, *args, **options):
        """ Adds workers with random names to the database

        To populate the database, run: 
        >>> python manage.py seed_workers -w 10 20 30 40 50

        Thus, in the first hierarchy there will be 10 users.
        In the second hierarchy - 20.
        And so on until five
        """

        workers_previous_hierarchy = []
        list_workers = self._normalized_list(options['workers'])
        
        for hierarchy in range(5):

            _workers_created = []

            for i in range(list_workers[hierarchy]):
                new_employee = Employee.objects.create(**self.random_dict_employee(workers_previous_hierarchy))
                _workers_created.append(new_employee)

            workers_previous_hierarchy = _workers_created


            print("Create {} workers in {} hierarchy.".format(
                    len(_workers_created),
                    str(hierarchy + 1)
                ))
            print(workers_previous_hierarchy)


    def random_dict_employee(self, chief_model_list=[]):
        """ Returns a dictionary with random values ​​to fill in the Employee model. """

        faker = Faker('uk_UA')
        random_object = random.choice(chief_model_list) if chief_model_list else None

        return {
                'name': faker.name(),
                'work_position': faker.job(),
                'wage': random.randint(300, 4000),
                'chief': random_object
            }


    def add_arguments(self, parser):
        """ Run command with arguments [-w / --workers] [1 2 3 4 5] """

        parser.add_argument(
            '-w',
            '--workers',
            nargs='+',
            default=[0],
            type=list,
            help="Number of employees to be created in the database"
        )


    def _normalized_list(self, cur_list, recurs=False):
        """ Lists arguments in normalized form. """

        result_str = ''
        result_list = []
        default_list = [1, 2, 3, 4, 5]

        for element in cur_list:
            if isinstance(element, str) or isinstance(element, int):
                result_str += str(element)
                continue
            else:
                result_list.extend(self._normalized_list(element, recurs=True))

        try:
            result_list.append(int(result_str))
        except ValueError:
            pass

        if len(result_list) != 5 and not recurs:
            return default_list

        return result_list