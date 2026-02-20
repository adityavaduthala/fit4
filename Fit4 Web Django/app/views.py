from django.shortcuts import render
from django.http import *
from app.models import *
from datetime import date

from django.http import JsonResponse

from django.core.files.storage import FileSystemStorage

# Create your views here.


def home(request):
    return render(request,"home.html")

def admin(request):
    return render(request,"admin.html")

def public_login(request):
    if request.method=='POST':
        uname=request.POST['uname']
        psw=request.POST['psw']

        print(uname,psw)

        try :

            z=login.objects.get(username=uname,password=psw)

            if z.usertype=='admin':
                return HttpResponse("""<script>alert("Login Success");window.location='adm'</script>""")
            

        except:
           pass

    return render(request,"login.html")


def register(request):
    if request.method=='POST':
    
        Name=request.POST['Name']
        Phone=request.POST['Phone']
        email=request.POST['email']
        age=request.POST['age']
        gender=request.POST['gender']
        height=request.POST['height']
        weight=request.POST['weight']
        Username=request.POST['Username']
        password=request.POST['password']

        print(Name,email,Phone,age,gender,height,weight,Username,password)

        res1=login(Username=Username,password=password,usertype='User')
        res1.save()

        res2=user(Username=Username,password=password,usertype='User')
        res2.save()

        

        return HttpResponse("""<script>alert("Login Success");window.location='adm'</script>""")



    return render(request,"register.html")


def lvlmanage(request):
    if request.method=='POST':
        lev=request.POST['level']

        res1=level(Lname=lev)
        res1.save()
        return HttpResponse("""<script>alert("Level insertion Success");window.location='lvlmanage'</script>""")
    
    result = level.objects.all()

    return render(request,"lvlmanagement.html",{'level':result})


def emanagement(request):


    z=category.objects.all()

    if request.method=='POST':
        exer=request.POST['Exercise']
        gif=request.FILES['gif']
        f=FileSystemStorage()
        gi=f.save(gif.name,gif)
        Fdetails=request.POST['Fdetails']
        cid=request.POST['cid']
        day1=request.POST['day1']
        day2=request.POST['day2']

        res1=Exercise(Ename=exer,file=gi,Format_details=Fdetails,Category_id=cid,day1=day1,day2=day2)
        res1.save()
        return HttpResponse("""<script>alert("Exercise insertion Success");window.location='emanagement'</script>""")
    
    result = Exercise.objects.all()

    return render(request,"emanagement.html",{'Exercise':result,'z':z})


def catmanage(request):
    a=level.objects.all()
    result=category.objects.all()

    print(result,"/////////")


    if request.method=='POST':
        Cname=request.POST['Cname']
        lid=request.POST['lid']

        res1=category(Cname=Cname,level_id=lid)
        res1.save()
        return HttpResponse("""<script>alert("Level insertion Success");window.location='catmanage'</script>""")
    

    

    return render(request,"catmanagement.html",{'a':a,'b':result})

def usermanage(request):

    result = user.objects.all()


    return render(request,"usermanagement.html",{'user':result})

def achievements(request):
    result = Achievement.objects.all()

    # print(result.exercise.Ename,"+++++++++++++++++")


    return render(request,"achievements.html",{'ach':result})


def complaints(request):
    result = complaint.objects.filter(reply='pending')


    return render(request,"viewcomplaints.html",{'vcomplaints':result})



def notification(request):
    result=Notification.objects.all()


    if request.method=='POST':
        ntext=request.POST['notification']

        res1=Notification(Not_text=ntext,date=date.today())
        res1.save()
        return HttpResponse("""<script>alert("Notification sent successfully");window.location='notification'</script>""")


    return render(request,"notification.html",{'notification':result})

# def achievements(request):


#     return render(request,"achievements.html")

def replycomplaints(request,id):
    result = complaint.objects.get(complaint_id=id)
    if request.method=='POST':
        result.reply=request.POST['rcomplaints']

        result.save()
        return HttpResponse("""<script>alert("Reply sent successfully");window.location='/complaints'</script>""")
    

    return render(request,"replycomplaints.html")

def level_delete(request,id):
    result = level.objects.get(Level_id=id)
    result.delete()
    return HttpResponse("""<script>alert("Level deleted successfully");window.location='/lvlmanage'</script>""")

def exercise_delete(request,id):
    result = Exercise.objects.get(Exercise_id=id)
    result.delete()
    return HttpResponse("""<script>alert("Level deleted successfully");window.location='/lvlmanage'</script>""")

def notif_delete(request,id):
    result = Notification.objects.get(Noti_id=id)
    result.delete()
    return HttpResponse("""<script>alert("Notification deleted successfully");window.location='/notification'</script>""")

def cat_delete(request,id):
    result = category.objects.get(Category_id=id)
    result.delete()
    return HttpResponse("""<script>alert("Category deleted succesfully");window.location='/catmanage'</script>""")






################################# User Module #################################

def and_login(request):



    u=request.POST['username']
    p=request.POST['password']

    print(u,p,"//////////")

    try:

        z=login.objects.get(username=u,password=p)
        if z.usertype=='User':
            return JsonResponse({'status':'user','lid':z.pk})
        else:
            return JsonResponse({'status':'error'})


            
    
    except:
        return JsonResponse({'status':'error'})






    return JsonResponse({'status':'login'})





def and_res(request):


    name=request.POST['name']
    age=request.POST['age']
    phone=request.POST['phone']
    gender=request.POST['gender']
    email=request.POST['email']
    height=request.POST['height']
    weight=request.POST['weight']
    username=request.POST['username']
    password=request.POST['password']

    print(name,age,phone,email,height,weight,username,password,"//////////")

    res1=login(username=username,password=password,usertype='User')
    res1.save()
    res2=user(Name=name,email=email,Phone=phone,age=age,gender=gender,height=height,weight=weight,login=res1)
    res2.save()
    print(res2,"////////////////")

    return JsonResponse({'status':'user'})

def profile(request):
    c=user.objects.all()
    data=[]
    for i in c:
        pdata={'pid':i.pk,'pname':i.Name,'pAge':i.age,'pgender':i.gender,'pheight':i.height,'pweight':i.weight}
        data.append(pdata)
        print(data)
    return JsonResponse({"status":"ok","data":data})


from django.http import JsonResponse

import json

def update_profile(request):
    if request.method == "POST":
        try:
            # Get data from the request
            data = json.loads(request.body)
            print(data,"//////")
            user_id = data['user_id']
            name = data['name']
            age = data['age']
       
            height = data['height']
            weight = data['weight']
            print(user_id,"///////")

            # Fetch user and update their details
            use = user.objects.get(login_id=user_id)
            use.Name = name
            use.age = age
       
            use.height = height
            use.weight = weight
            use.save()

            return JsonResponse({"status": "ok"})

        except Exception as e:
            print(f"Error updating profile: {e}")
            return JsonResponse({"status": "error", "message": "Failed to update profile"})


def Levels(request):
    print(request.POST)
    c=level.objects.all()
    data=[]
    for i in c:
        ldata={'lid':i.pk,'lname':i.Lname}
        data.append(ldata)
    return JsonResponse({"status":"ok","data":data})

def categorys(request):
    print(request.POST)
    lid = request.POST.get('lid')
    print(lid)
    c=category.objects.filter(level_id=lid)
    data=[]
    for i in c:
        cdata={'Cid':i.pk,'Cname':i.Cname}
        data.append(cdata)
    print(data,"////////")
    return JsonResponse({"status":"ok","data":data})

def exercises(request):
    cid = request.POST.get('cid')
    # print(lid)
    e=Exercise.objects.filter(Category_id=cid)
    data=[]
    for i in e:
        cdata={'Exercise_id':i.pk,'Ename':i.Ename,'Format_details':i.Format_details,'file':i.file,'Category_id':i.Category_id,'day1':i.day1,'day2':i.day2}
        data.append(cdata)
    print(data,"////////")
    return JsonResponse({"status":"ok","data":data})

def achievement(request):
    # lid = request.POST.get('lid')
    # print(lid)
    e=Achievement.objects.all()
    data=[]
    for i in e:
        cdata={'ach_id':i.pk,'completed_date':i.completed_date,'exercise_id':i.exercise.Ename,'user_id':i.user.Name}
        data.append(cdata)
    print(data,"////////")
    return JsonResponse({"status":"ok","data":data})





def get_levels(request):
    levels = level.objects.all()
    data=[]
    for i in levels:
        cdata={'level_id':i.pk,'lname':i.Lname}
        data.append(cdata)
    print(data,"////////")
    return JsonResponse({"status":"ok","data":data})

from .models import category

def get_categories(request):
    level_id = request.GET.get("level_id")  # Get level ID from request parameters
    categories = category.objects.filter(level_id=level_id)
    data = [{'category_id': cat.Category_id, 'cname': cat.Cname} for cat in categories]
    
    print(data, "////////")
    return JsonResponse({"status": "ok", "data": data})

from .models import Exercise

def get_exercises(request):
    category_id = request.GET.get("category_id")  # Get category ID from request parameters
    exercises = Exercise.objects.filter(Category_id=category_id)
    data = [
        {
            'exercise_id': ex.Exercise_id,
            'ename': ex.Ename,
            'format_details': ex.Format_details,
            'file': ex.file,
            'day1': ex.day1,
            'day2': ex.day2
        }
        for ex in exercises
    ]
    
    print(data, "////////")
    return JsonResponse({"status": "ok", "data": data})

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from datetime import datetime


@csrf_exempt
def add_achievement(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            user_id = data.get("user_id")
            exercise_id = data.get("exercise_id")
            level_id = data.get("level_id")
            cat_id = data.get("cat_id")
            goals = data.get("goals")
            completed_date = datetime.strptime(data.get("date"), "%Y-%m-%d").date()

            # Ensure user, exercise, level, and category exist
            use = user.objects.get(login_id=user_id)
            exe = Exercise.objects.get(Exercise_id=exercise_id)
            leve = level.objects.get(pk=level_id)
            categor = category.objects.get(pk=cat_id)

            # Save achievement
            achievement = Achievement.objects.create(
                user=use,
                exercise=exe,
                level=leve,
                cat=categor,
                goals=goals,
                date=completed_date
            )
            achievement.save()

            return JsonResponse({"status": "ok", "message": "Achievement saved successfully!"})

        except Exception as e:
            print(e)
            return JsonResponse({"status": "error", "message": str(e)})

    return JsonResponse({"status": "error", "message": "Invalid request"})


def get_achievements(request):
    try:
        user_id = request.POST.get('user_id')  # Fetch user_id from the request
        use = user.objects.get(login_id=user_id)
        print(user_id,"///////")
        if not use:
            return JsonResponse({'status': 'error', 'message': 'User ID is required'})

        achievements_data = Achievement.objects.filter(user_id=use).values(
            'exercise_id', 'goals', 'date'
        )
        return JsonResponse({'status': 'ok', 'data': list(achievements_data)})
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)})
