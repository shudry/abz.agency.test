from rest_framework import serializers
from manager_employee.models import Employee


class EmployeeSerializer(serializers.ModelSerializer):
	class Meta:
		model = Employee
		fields = ('id', 'name', 'work_position', 'chief')


class EmployeeSerializerIsAuthenticated(serializers.ModelSerializer):
	class Meta:
		model = Employee
		fields = ('id', 'name', 'work_position', 'date_join', 'wage', 'chief')