from django.shortcuts import render, redirect
from django.views import View
from django.http import HttpResponseNotFound
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, logout
from django.contrib.auth import login as auth_login
from django.db.models import Q

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .serializers import EmployeeSerializer, EmployeeSerializerIsAuthenticated
from .models import Employee
# Create your views here.


class MainPage(View):

    template_name = 'home.html'

    def __init__(self, *args, **kwargs):
        self.context_data = {}
        self.get_static_context

    def get(self, request):
        self.context_data['error_login'] = request.GET.get('error-login', None)
        return render(request, self.template_name, self.context_data)

    @property
    def get_static_context(self):
        self.context_data['page_name'] = "Employees manager"


class AuthenticateUser(View):
    def post(self, request):
        username = request.POST.get('username', None)
        password = request.POST.get('password', None)

        if not username or not password:
            return self._redirect_with_error('/', 'Заповніть пусті поля')

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            return self._redirect_with_error('/', 'Данний нікнейм в базі не знайдено')

        user_auth = authenticate(username=user.username, password=password)

        if user_auth is not None:
            if user_auth.is_active:
                auth_login(request, user_auth)
                return redirect('/')

        return self._redirect_with_error('/', 'Невірний пароль. Спробуйте ще раз')


    def _redirect_with_error(self, url, error_text):
        return redirect('{url}?error-login={error}'.format(url=url, error=error_text))


def auth_logout(request):
    if request.user.is_authenticated:
        logout(request)
    return redirect('/')


class RestEmployee(viewsets.ModelViewSet):
    queryset = Employee.objects.all()
    queryclass = Employee

    @action(detail=True, methods=['get'])
    def subordinates(self, request, pk=None):
        """ Shows all subordinate chief """

        employee = self.get_object()
        recent_employees = self.get_queryset().filter(chief=employee)

        return self._response_paginated_queryset(recent_employees)


    @action(detail=False, methods=['get'])
    def withoutchief(self, request):
        """ Shows all employees who do not have a boss """

        recent_employees = self.get_queryset().filter(chief=None)

        return self._response_paginated_queryset(recent_employees)


    @action(detail=False, methods=['get'])
    def search(self, request):
        data = request.GET.get('data', '')
        
        if not data:
            response = {'detail': 'Parameter <data> is empty'}
            return Response(response, status=status.HTTP_400_BAD_REQUEST)

        recent_employees = self.queryclass.objects.none()

        # Send to server data:
        #   name__icontains=thisisdata,seconddata|work_position__test=...
        
        for fad in data.split('|'):
            fad_name_data = fad.split('=')
            
            #   fad_name_data -> 
            #       [0]:    name__icontains
            #       [1]:    thisisdata,seconddata

            name_field = fad_name_data[0].split('__')[0]
            
            if name_field in ['name', 'work_position', 'date_join']:
                data_field_list = fad_name_data[1].split(',') # ['thisisdata', 'seconddata']
                
                if data_field_list[0] is not None:
                    cache_recent_employees = self.get_queryset().filter(
                            self._matching_filter__in(fad_name_data[0], data_field_list)
                        )

                    if recent_employees.count() == 0:
                        recent_employees = cache_recent_employees
                    else:
                        recent_employees = recent_employees & cache_recent_employees

            elif name_field == 'wage':
                data_field_list = fad_name_data[1].split(',') # ['0', '100']
                
                cache_recent_employees = self.queryclass.objects.none()

                for fad_data in data_field_list:
                    if '-' in fad_data:
                        # In the range from and to
                        from_range, to_range = int(fad_data.split('-')[0]), int(fad_data.split('-')[1])
                            
                        cache_recent_employees = cache_recent_employees | self.get_queryset().filter(
                                **{'wage__range': tuple([from_range, to_range])}
                            )
                    else:
                        if fad_data is None:
                            continue

                        # Get queryset objects wage==first integer|float
                        cache_recent_employees = cache_recent_employees | self.get_queryset().filter(
                                **{'wage': fad_data}
                            )

                if recent_employees.count() == 0:
                    recent_employees = cache_recent_employees
                else:
                    recent_employees = recent_employees & cache_recent_employees

        return self._response_paginated_queryset(recent_employees)


    def _matching_filter__in(self, field_name, data_list):
        """ List of objects according to the search data list """

        qset = Q()
        for i in data_list:
            qset |= Q(**{field_name: i})
        return qset



    def get_serializer_class(self):
        """ If the user is logged in, display all fields of the model """

        if self.request.user.is_authenticated:
            return EmployeeSerializerIsAuthenticated

        return EmployeeSerializer


    def _response_paginated_queryset(self, queryset):
        """ Send a response broken down by page """

        page = self.paginate_queryset(queryset)
        
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)