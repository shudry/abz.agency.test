$ = jQuery

class AJAXEmployeesManager

    shownFirstWorkersId = {}

    constructor: (@firstCount, @secondCount) ->

    getEmployee: (url, requestDone) ->
        request = $.ajax 
            url: url
            type: "GET"

        request.fail @AJAXerrorGetWorkers
        request.done requestDone

    AJAXerrorGetWorkers: (jqXHR, textStatus, errorThrown) ->
        #error request AJAX
        console.log "Error: #{jqXHR}, #{textStatus}, #{errorThrown}"


    appendElementToDOM = (element) ->
        html = """
            <div class="employee" id="employee-id-#{element.id}">
                <div class="row">
                    <div class="col-md-1 employee-image"><i class="fas fa-user-tie fa-2x"></i></div>
                    <div class="col-md-3">
                      <p>#{element.name}</p>
                    </div>
                    <div class="col-md-2">
                      <p>#{element.work_position}</p>
                    </div>
                    <div class="col-md-2">
                      <p>#{element.wage}</p>
                    </div>
                    <div class="col-md-2">
                      <p>#{element.date_join}</p>
                    </div>
                    <div class="col-md-2">
                      <p>#{element.id}</p>
                    </div>
                </div>
            </div>
        """

    appendElementLoadMore = (element_chief) ->
        html = """
            <div class="employee load-more-empl" id="employee-load-more-#{element_chief}">
                <div class="row justify-content-md-center">
                    <div class="col-md-auto">
                        <a href="#load-more" class="employee-load-more-link btn btn-default" id="#{element_chief}">Загрузити ще ...</a>
                    </div>
                </div>
            </div>
        """


    showFirstHierarchy: (count, urlNext) ->
        url = urlNext or "/employee/withoutchief/?limit=#{count}"
        thisContext = this

        @getEmployee url, (data, textStatus, jqXHR) ->
            if data.results or data.count > 0 or not data.next
                $("#employee-load-more-first-loads").remove()

            #Show warning alerts "employees not found"
            if Object.keys(shownFirstWorkersId).length == 0
                if not data.results or data.count == 0
                    $('#not-found-employees-warning').css(
                            display: "block"
                        )

            for element in data.results
                if not shownFirstWorkersId[element.id]
                    shownFirstWorkersId[element.id] = {
                        self: element,
                        subordinates: {}
                    }
                    $(".container-workers").append(appendElementToDOM element)
                    
                    #Initialization show subordinates(second hierarchy)
                    thisContext.showSecondHierarchy element.id, null, thisContext.secondCount                

            if data.next
                $(".container-workers").append(appendElementLoadMore "first-loads")
                $("#employee-load-more-first-loads").find("a").click (e) ->
                    thisContext.showFirstHierarchy count, data.next


    showSecondHierarchy: (elementID, urlNext, count) ->
        url = urlNext or "/employee/#{elementID}/subordinates/?limit=#{count}"
        thisContext = this

        @getEmployee url, (data, textStatus, jqXHR) ->
            if data.results or data.count > 0 or not data.next
                $("#employee-load-more-#{elementID}").remove()
            
            # Append employees to chief
            for employee in data.results
                if not shownFirstWorkersId[employee.chief].subordinates[employee.id]
                    shownFirstWorkersId[employee.chief].subordinates[employee.id] = employee
                    $("#employee-id-#{employee.chief}").append(appendElementToDOM employee)
            
            if data.next
                $("#employee-id-#{elementID}").append(appendElementLoadMore elementID)
                $("#employee-load-more-#{elementID}").find("a").click (e) ->
                    thisContext.showSecondHierarchy e.target.id, data.next, thisContext.secondCount


    hideAllEmployeesInContainer: () ->
        for element in Object.keys(shownFirstWorkersId)
            $("employee-id-#{element}").css(
                    display: "none"
                )

        $("#employee-load-more-first-loads").css(
                display: "none"
            )

    showAllEmployeesInContainer: () ->
        for element in Object.keys(shownFirstWorkersId)
            $("employee-id-#{element}").css(
                    display: "block"
                )

        $("#employee-load-more-first-loads").css(
                display: "block"
            )


    showEmployees: () ->
        @showFirstHierarchy @firstCount

    #showSecond: () ->
    #    for element in Object.keys(shownFirstWorkersId)
    #        if not shownFirstWorkersId[element].isAlreadyInitialize
    #            @showSecondHierarchy element, @secondCount

    getListWorkers: () ->
        return shownFirstWorkersId




$(document).ready ->
    me2 = new AJAXEmployeesManager 40, 10
    me2.showEmployees()


    delay = (callback, ms=1000) ->
        timer = 0;
        return () ->
            context = this
            args = arguments
            clearTimeout timer

            callbackRet = () ->
                callback.apply context, args

            timer = setTimeout callbackRet, ms || 0


    # Input search by name
    $('#search-by-name-field').keyup delay (e) ->
        data = e.currentTarget.value
        
        if data.length >= 3        
            if "|" in data
                result_data = data.split("|")

                last = result_data[result_data.length - 1]
                if last.length >= 3
                    fieldSearchByName result_data
            else
                fieldSearchByName [data]


    fieldSearchByName = (stringData) ->
        url = "/employee/search/"
        send_data = {
            limit: 20
            fieldName: "name__icontains"
            data: stringData.join()
        }
        #console.log data
        searchRequestToServer url, send_data, (data, textStatus, jqXHR) ->
            #this is success function
            console.log data


    searchRequestToServer = (url, requestData, requestDone) ->
        request = $.ajax 
            url: url
            type: "GET"
            data: requestData

        request.fail searchRequestError
        request.done requestDone

    searchRequestError = (jqXHR, textStatus, errorThrown) ->
        console.log "------ Error search request -----"
        console.log errorThrown