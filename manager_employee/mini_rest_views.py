from django.views import View
from django.http import JsonResponse
from .models import Employee



class WorkersManager(View):

	def get(self, request):
		boss = str(request.GET.get('boss', ''))
		count = int(request.GET.get('count', 0))
		un_id_get = request.GET.get('unnecessaryId', '')
		
		unnecessary_id = un_id_get.split(',') if un_id_get != '' else []


		if boss == 'first-hierarchy':
			workers = Employee.objects.filter(chief=None)\
				.exclude(id__in=unnecessary_id)[:count]
		else:
			workers = Employee.objects.filter(chief__id=int(boss))\
				.exclude(id__in=unnecessary_id)[:count]

		return JsonResponse(list(workers.values('id', 'work_position', 'chief')), safe=False)


	def post(self, request):
		pass