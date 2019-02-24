from django.core.management.base import BaseCommand
from manager_employee.models import Employee
from django.conf import settings


class Command(BaseCommand):

    help = "Filling employee base with random values"

    def handle(self, *args, **options):
    	if settings.DEBUG:
	        Employee.objects.all().delete()
	        print("All workers are romoved succesfuly")
    	else:
        	print("You not remove workers, set debug=True.")       
