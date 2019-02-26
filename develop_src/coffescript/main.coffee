$ = jQuery

class AJAXWorkersManager

    shownFirstWorkersId = []

    constructor: (@container) ->

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
                unnecessaryId: encodeURI(shownFirstWorkersId.join())
            async: false
        
        if bossId == "first-hierarchy"
            request.done @AJAXsuccessGetWorkers
            request.fail @AJAXerrorGetWorkers
        else
            #request.done @AJAXsuccessGetWorkers
            #request.fail @AJAXerrorGetWorkers


    AJAXsuccessGetWorkers: (data, textStatus, jqXHR) ->
        #success request AJAX

        frn = (element) ->
            shownFirstWorkersId.push element.id
            html = """
                <div class="employee row">
                <div class="col-md-3"><img src="https://avatars0.githubusercontent.com/u/31619203?s=40&amp;v=4" alt="Logo" width="50" height="50" class="img-circle"/></div>
                <div class="col-md-3">
                  <p>#{element.name}</p>
                </div>
                <div class="col-md-3">
                  <p>#{element.work_position}</p>
                </div>
                <div class="col-md-3">
                  <p>#{element.chief}</p>
                </div>
                </div>
            """   
            $('.container-workers').append(html)

        frn element for element in data

    AJAXerrorGetWorkers: (jqXHR, textStatus, errorThrown) ->
        #error request AJAX
        console.log "Error: #{jqXHR}, #{textStatus}, #{errorThrown}"


    showFirstHierarchy: (count=100) ->
        ### Display list first hierarchy 

        count: Get count users
        ###

        @getWorkersBoss "first-hierarchy", count

    showWorkersInTree: (parentEmployeeContainer) ->
        ### Show 2 and more hierarchy workers ###

    getShownedListId: () ->
        console.log shownFirstWorkersId




$(document).ready ->
    me2 = new AJAXWorkersManager ".container-workers"
    
    me2.showFirstHierarchy()
