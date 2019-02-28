$ = jQuery

class AJAXWorkersManager

    shownFirstWorkersId = {}

    getWorkersBoss: (bossId, count) ->
        ### Get subordinates boss
        
        bossId: Id user.
            If bossId = "first-hierarchy" show users who are not have boss.
        
        count: Count list workers.

        listUnnecessaryId: Already get and show workers.
            No need to re-receive.
        ###

        #shownFirstWorkersId.push 20
        #console.log shownFirstWorkersId

        request = $.ajax 
            url: "/workers/"
            type: "GET"
            data: 
                boss: bossId
                count: count
                unnecessaryId: encodeURI(Object.keys(shownFirstWorkersId).join())
            async: false
        
        if bossId == "first-hierarchy"
            request.done (data, textStatus, jqXHR) ->
                $('.container-workers').append(appendElementToDOM element) for element in data
        else
            request.done (data, textStatus, jqXHR) ->
                $("#employee-id-#{element.chief}").append(appendElementToDOM element) for element in data
        
        request.fail @AJAXerrorGetWorkers


    AJAXerrorGetWorkers: (jqXHR, textStatus, errorThrown) ->
        #error request AJAX
        console.log "Error: #{jqXHR}, #{textStatus}, #{errorThrown}"


    appendElementToDOM = (element) ->
        shownFirstWorkersId[element.id] = {}
        element_chief = if element.chief then element.chief else ''
        html = """
            <div class="employee" id="employee-id-#{element.id}">
                <div class="row">
                    <div class="col-md-3"><img src="https://avatars0.githubusercontent.com/u/31619203?s=40&amp;v=4" alt="Logo" width="50" height="50" class="img-circle"/></div>
                    <div class="col-md-3">
                      <p>#{element.name}</p>
                    </div>
                    <div class="col-md-3">
                      <p>#{element.work_position}</p>
                    </div>
                    <div class="col-md-3">
                      <p>#{element_chief}</p>
                    </div>
                </div>
            </div>
        """

    showFirstHierarchy: (count=100) ->
        ### Display list first hierarchy 

        count: Get count users
        ###

        @getWorkersBoss "first-hierarchy", count


    showWorkersSecondHierarchy: (count=100) ->
        ### Show 2 and more hierarchy workers ###

        for employee in Object.keys(shownFirstWorkersId)
            #console.log "employee-id-#{employee}"
            @getWorkersBoss employee, count


    showListWorkers: () ->
        console.log shownFirstWorkersId




$(document).ready ->
    me2 = new AJAXWorkersManager
    
    me2.showFirstHierarchy()
    me2.showListWorkers()

    me2.showWorkersSecondHierarchy()
