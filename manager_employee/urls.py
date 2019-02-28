from django.urls import path
from .views import MainPage, AuthenticateUser

urlpatterns = [
    path('login/', AuthenticateUser.as_view()),
    path('', MainPage.as_view(), name='main_page'),
]