from django.db import models

# Create your models here.

# login

class login(models.Model):
    login_id=models.AutoField(primary_key=True)
    username=models.CharField(max_length=200)
    password=models.CharField(max_length=200)
    usertype=models.CharField(max_length=200)

# user or registration page

class user(models.Model):
    user_id=models.AutoField(primary_key=True)
    login=models.ForeignKey(login,on_delete=models.CASCADE)
    Name=models.CharField(max_length=200)
    email=models.CharField(max_length=200)
    Phone=models.CharField(max_length=200)
    age=models.CharField(max_length=200)
    gender=models.CharField(max_length=200)
    height=models.CharField(max_length=200)
    weight=models.CharField(max_length=200)
    
   
# level 

class level(models.Model):
    Level_id=models.AutoField(primary_key=True)
    Lname=models.CharField(max_length=200)

# category

class category(models.Model):
    Category_id=models.AutoField(primary_key=True)
    level=models.ForeignKey(level,on_delete=models.CASCADE)
    Cname=models.CharField(max_length=200)

# Exercise

class Exercise(models.Model):
    Exercise_id =models.AutoField(primary_key=True)
    Ename=models.CharField(max_length=200)
    Category=models.ForeignKey(category,on_delete=models.CASCADE)
    Format_details=models.CharField(max_length=200)
    file=models.CharField(max_length=200)
    day1=models.CharField(max_length=200)
    day2=models.CharField(max_length=200)


# Achievements

class Achievement(models.Model):
    ach_id = models.AutoField(primary_key=True)
    level= models.ForeignKey(level,on_delete=models.CASCADE)
    cat= models.ForeignKey(category,on_delete=models.CASCADE)
    exercise= models.ForeignKey(Exercise,on_delete=models.CASCADE)
    user= models.ForeignKey(user,on_delete=models.CASCADE)
    goals = models.CharField(max_length=200)
    date=models.CharField(max_length=200)


# Complaints

class complaint(models.Model):
    complaint_id=models.AutoField(primary_key=True)
    login=models.ForeignKey(login,on_delete=models.CASCADE)
    description=models.CharField(max_length=200)
    reply=models.CharField(max_length=200)
    date=models.CharField(max_length=200)

# notification

class Notification(models.Model):
    Noti_id=models.AutoField(primary_key=True)
    Not_text=models.CharField(max_length=200)
    date=models.CharField(max_length=200)