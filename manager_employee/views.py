from django.shortcuts import render
from django.views import View
from django.http import HttpResponseNotFound

from .models import Employee
# Create your views here.

#
# Sublime text: ctrl+shift+p disable pep8 autoformat
#

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
        self.context_data['workers'] = Employee.objects.all()


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