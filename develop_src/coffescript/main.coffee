$ = jQuery

class AJAXWorkersManager

    shownFirstWorkersId = {}

    getWorkersBoss: (bossId, count) ->
        ### Get subordinates boss ###

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

                # If all employees are loaded from the database, hide the “load more” button
                # For only first hierarchy
                if data.length == 0 or data.length < count
                    $('.load-more-workers').css
                        display: 'none'

                for element in data
                    if not shownFirstWorkersId[element.id]
                        shownFirstWorkersId[element.id] = {}
                        $('.container-workers').append(appendElementToDOM element)
        else
            request.done (data, textStatus, jqXHR) ->
                for element in data
                    if not shownFirstWorkersId[element.chief][element.id]
                        shownFirstWorkersId[element.chief][element.id] = element
                        $("#employee-id-#{element.chief}").append(appendElementToDOM element)
        
        request.fail @AJAXerrorGetWorkers


    AJAXerrorGetWorkers: (jqXHR, textStatus, errorThrown) ->
        #error request AJAX
        console.log "Error: #{jqXHR}, #{textStatus}, #{errorThrown}"


    appendElementToDOM = (element) ->
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

    showFirstHierarchy: (count=50) ->
        ### Display list first hierarchy ###
        @getWorkersBoss "first-hierarchy", count


    showWorkersSecondHierarchy: (count=50) ->
        ### Show 2 hierarchy workers ###
        @getWorkersBoss "second-hierarchy", count


    showListWorkers: () ->
        console.log shownFirstWorkersId




$(document).ready ->
    me2 = new AJAXWorkersManager
    
    me2.showFirstHierarchy(40)
    me2.showListWorkers()

    me2.showWorkersSecondHierarchy()

    $(".load-more-workers").click () ->
        me2.showFirstHierarchy(40)
        me2.showWorkersSecondHierarchy()
