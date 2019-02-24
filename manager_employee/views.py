from django.shortcuts import render
from django.views import View

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
