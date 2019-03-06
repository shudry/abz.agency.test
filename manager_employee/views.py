from django.shortcuts import render, redirect
from django.views import View
from django.http import HttpResponseNotFound
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, logout
from django.contrib.auth import login as auth_login

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
            return self._redirect_with_error('/', 'Sent data is incorrect')

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            return self._redirect_with_error('/', 'Username not found')

        user_auth = authenticate(username=user.username, password=password)

        if user_auth is not None:
            if user_auth.is_active:
                auth_login(request, user_auth)
                return redirect('/')

        return self._redirect_with_error('/', 'Password is not valid')


    def _redirect_with_error(self, url, error_text):
        return redirect('{url}?error-login={error}'.format(url=url, error=error_text))


def auth_logout(request):
    if request.user.is_authenticated:
        logout(request)
    return redirect('/')


class RestEmployee(viewsets.ModelViewSet):
    queryset = Employee.objects.all()

    @action(detail=True, methods=['get'])
    def subordinates(self, request, pk=None):
        """ Shows all subordinate chief """

        employee = self.get_object()
        recent_employees = self.get_queryset().filter(chief=employee)

        return self._get_response_paginated_queryset(recent_employees)


    @action(detail=False, methods=['get'])
    def withoutchief(self, request):
        """ Shows all employees who do not have a boss """

        recent_employees = self.get_queryset().filter(chief=None)

        return self._get_response_paginated_queryset(recent_employees)


    @action(detail=False, methods=['get'])
    def search(self, request):
        field_name = request.GET.get('fieldName', '')
        data = request.GET.get('data', '')
        
        print("REQUEST DATA: {}".format(data))

        if not field_name or not data:
            response = {'detail': 'No parameter <fieldName> or <data>'}
            return Response(response, status=status.HTTP_400_BAD_REQUEST)

        filter_kwargs = {}
        recent_employees = []
        if field_name.split('__')[0] in ['name', 'work_position', 'date_join', 'wage']:
            for search_field in data.split(','):
                filter_kwargs[field_name] = search_field
                recent_employees.extend(self.get_queryset().filter(**filter_kwargs))

            return self._get_response_paginated_queryset(recent_employees)
        
        response = {'detail': '<fieldName> is incorrect'}
        return Response(response, status=status.HTTP_400_BAD_REQUEST)


    def get_serializer_class(self):
        """ If the user is logged in, display all fields of the model """

        if self.request.user.is_authenticated:
            return EmployeeSerializerIsAuthenticated

        return EmployeeSerializer


    def _get_response_paginated_queryset(self, queryset):
        """ Send a response broken down by page """

        page = self.paginate_queryset(queryset)
        
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)