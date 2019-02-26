$ = jQuery

class AJAXWorkersManager

    shownFirstWorkersId = []

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
        shownFirstWorkersId.push element.id for element in data


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
    me2 = new AJAXWorkersManager
    
    me2.showFirstHierarchy()
