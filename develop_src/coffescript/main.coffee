$ = jQuery

class AJAXWorkersManager

    shownFirstWorkersId = {}

    getWorkersBoss = (bossId, count, unnecessaryList) ->
        ### Get subordinates boss ###

        unnecesList = if unnecessaryList then unnecessaryList else shownFirstWorkersId

        request = $.ajax 
            url: "/workers/"
            type: "GET"
            data: 
                boss: bossId
                count: count
                unnecessaryId: encodeURI(Object.keys(unnecesList).join())
            async: false
        
        if bossId == "first-hierarchy"
            request.done (data, textStatus, jqXHR) ->

                # If all employees are loaded from the database, hide the “load more” button
                # For only first hierarchy
                if data.length == 0 or data.length < count
                    $('.load-more-workers').remove()

                for element in data
                    if not shownFirstWorkersId[element.id]
                        shownFirstWorkersId[element.id] = {}
                        $('.container-workers').append(appendElementToDOM element)
        
        else
            request.done (data, textStatus, jqXHR) ->

                exist_show_more = []

                if data.length == 0 or data.length < count
                    $("#employee-load-more-#{e.target.id}").remove()

                for element in data
                    if Object.keys(shownFirstWorkersId[element.chief]).length >= count

                        if element.chief in exist_show_more
                            continue

                        result_code = $("#employee-id-#{element.chief}").append(appendElementLoadMore element.chief)
                        result_code.find("a").click (e) ->
                            getWorkersBoss e.target.id, count, shownFirstWorkersId[e.target.id]
                            $("#employee-load-more-#{e.target.id}").remove()

                        exist_show_more.push element.chief
                        continue

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

    appendElementLoadMore = (element_chief) ->
        html = """
            <div class="employee" id="employee-load-more-#{element_chief}">
                <div class="row justify-content-md-center">
                    <div class="col-md-auto">
                        <a href="#load-more" class="employee-load-more-link btn btn-default" id="#{element_chief}">Загрузити ще ...</a>
                    </div>
                </div>
            </div>
        """


    showFirstHierarchy: (count=50) ->
        ### Display list first hierarchy ###
        getWorkersBoss "first-hierarchy", count


    showWorkersSecondHierarchy: (count=50) ->
        ### Show 2 hierarchy workers ###
        getWorkersBoss "second-hierarchy", count


    showListWorkers: () ->
        console.log shownFirstWorkersId




$(document).ready ->
    me2 = new AJAXWorkersManager
    
    me2.showFirstHierarchy(40)
    #me2.showListWorkers()
    me2.showWorkersSecondHierarchy(1)

    $(".load-more-workers").click () ->
        me2.showFirstHierarchy(40)
        #me2.showWorkersSecondHierarchy(2)
