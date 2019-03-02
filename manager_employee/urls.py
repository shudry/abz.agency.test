from django.urls import path, include
from .views import *

from rest_framework import routers

router = routers.SimpleRouter()
router.register(r'employee', RestEmployee)

urlpatterns = [
    path('login/', AuthenticateUser.as_view()),    
    path('', MainPage.as_view(), name='main_page'),
]

urlpatterns += router.urls
