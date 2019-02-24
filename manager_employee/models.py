from django.db import models
from django.utils import timezone
# Create your models here.


class Employee(models.Model):
	name = models.CharField(max_length=100, blank=True)
	work_position = models.CharField(max_length=50, blank=True)
	date_join = models.DateField(default=timezone.now().date())
	wage = models.FloatField(default=0.01)

	chief = models.ForeignKey('self', related_name='relate_chief', blank=True, null=True, on_delete=models.SET_NULL)

	def __str__(self, *args, **kwargs):
		return self.name