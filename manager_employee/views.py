from django.shortcuts import render
from django.views import View
from django.http import HttpResponseNotFound

from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .serializers import EmployeeSerializer
from .models import Employee
# Create your views here.


class MainPage(View):

    template_name = 'home.html'

    def __init__(self, *args, **kwargs):
        self.context_data = {}
        self.get_static_context

    def get(self, request):
        return render(request, self.template_name, self.context_data)

    @property
    def get_static_context(self):
        self.context_data['page_name'] = "Main context test"


class AuthenticateUser(View):

    def get(self, request):
        return HttpResponseNotFound('<h3>Not found this login page</h3>')

    def post(self, request):
        username = request.POST.get('username', None)
        password = request.POST.get('password', None)

        if username is None or password is None:
            return HttpResponseNotFound('<h1>Argument error</h1>')

        if not User.objects.filter(username=username):
            return HttpResponseNotFound('<h1>User not found</h1>')

        user_auth = authenticate(username=user.username, password=password)

        if user_auth is not None:
            if user_auth.is_active:
                auth_login(request, user_auth)
                return redirect('/')

        return HttpResponseNotFound('<h1>Password is not valid!</h1>')


class RestEmployee(viewsets.ModelViewSet):
    queryset = Employee.objects.all()
    serializer_class = EmployeeSerializer

    @action(detail=True, methods=['get'])
    def subordinates(self, request, pk=None):
        employee = self.get_object()
        recent_employees = self.get_queryset().filter(chief=employee)

        page = self.paginate_queryset(recent_employees)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(recent_employees, many=True)
        return Response(serializer.data)


    @action(detail=False, methods=['get'])
    def withoutchief(self, request):
        recent_employees = self.get_queryset().filter(chief=None)

        page = self.paginate_queryset(recent_employees)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = self.get_serializer(recent_employees, many=True)
        return Response(serializer.data)