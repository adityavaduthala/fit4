
from django.contrib import admin
from django.urls import path

from app import views

urlpatterns = [
    
    path('', views.public_login),
    path('user', views.register),
    path('adm', views.admin),
    path('lvlmanage', views.lvlmanage),
    path('emanagement', views.emanagement),
    path('catmanage', views.catmanage),
    path('usermanage', views.usermanage),
    path('notification', views.notification),
    path('achievements', views.achievements),
    path('complaints', views.complaints),
    path('replycomplaints/<id>', views.replycomplaints),
    path('level_delete/<id>', views.level_delete),
    path('exercise_delete/<id>', views.exercise_delete),
    path('notif_delete/<id>', views.notif_delete),
    path('cat_delete/<id>', views.cat_delete),



    path('and_login',views.and_login),
    path('and_res',views.and_res),
    path('profile',views.profile),
    path('Levels',views.Levels),
    path('categorys',views.categorys),
    path('exercises',views.exercises),
    path('achievement', views.achievement),

  
    path('get_levels/', views.get_levels, name='get_levels'),
    path('get_categories/', views.get_categories, name='get_categories'),
    path('get_exercises/', views.get_exercises, name='get_exercises'),
    path('add_achievement/', views.add_achievement, name='add_achievement'),
    path('get_achievements', views.get_achievements, name='get_achievements'),

     path('update_profile', views.update_profile, name='update_profile')
]







