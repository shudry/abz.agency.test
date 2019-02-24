import random

from django.core.management.base import BaseCommand
from faker import Faker

from manager_employee.models import Employee


class Command(BaseCommand):
    
    help = "Filling employee base with random values"

    def handle(self, *args, **options):

        workers_previous_hierarchy = []
        list_workers = self._current_list(options['workers'])
        
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
        
        faker = Faker('uk_UA')
        random_object = random.choice(chief_model_list) if chief_model_list else None

        return {
                'name': faker.name(),
                'work_position': faker.job(),
                'wage': random.randint(300, 4000),
                'chief': random_object
            }


    def add_arguments(self, parser):
        parser.add_argument(
            '-w',
            '--workers',
            nargs='+',
            default=[0],
            type=list,
            help="Number of employees to be created in the database"
        )


    def _current_list(self, cur_list, recurs=False):
        result_str = ''
        result_list = []
        default_list = [1, 2, 3, 4, 5]

        for element in cur_list:
            if isinstance(element, str) or isinstance(element, int):
                result_str += str(element)
                continue
            else:
                result_list.extend(self._current_list(element, recurs=True))

        try:
            result_list.append(int(result_str))
        except ValueError:
            pass

        if len(result_list) != 5 and not recurs:
            return default_list

        return result_list