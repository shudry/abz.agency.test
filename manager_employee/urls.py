from django.urls import path

from .views import MainPage
from .mini_rest_views import WorkersManager

urlpatterns = [
	path('workers/', WorkersManager.as_view(), name='rest_workers'),
	path('', MainPage.as_view(), name='main_page'),
]