$ = jQuery

# ___________________________ AJAXEmployeesManager ___________________________ CLASS __
# -------------------------------------------------------------------------------------
class AJAXEmployeesManager

    shownFirstWorkersId = {}

    constructor: (@firstCount, @secondCount, @managerPopUp) ->

    getEmployee: (url, requestDone) ->
        thisContext = this
        request = $.ajax 
            url: url
            type: "GET"

        request.done requestDone
        request.fail (jqXHR, textStatus, errorThrown) ->
            #error request AJAX
            thisContext.showErrorAlert errorThrown


    getLocationPathname: (href) ->
        l = document.createElement "a"
        l.href = href
        return l.pathname + l.search


    appendElementToDOM: (container, element, id) ->
        thisContext = this
        idElement = if id then "employee-#{id}-#{element.id}" else "employee-id-#{element.id}"
        html = """
            <div class="employee" id="#{idElement}">
                <div class="row" id="#{element.id}">
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
        $(container).append html
        $("##{idElement} > .row").click (e) ->
            thisContext.managerPopUp.show e.currentTarget.id


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


    showFirstHierarchy: (count, urlNext, isSearchResult=false) ->
        sorted = encodeURIComponent($('#select-sorted-by').val())
        url = urlNext or "/employee/withoutchief/?limit=#{count}&sorted=#{sorted}"
        thisContext = this

        @getEmployee url, (data, textStatus, jqXHR) ->
            if data.results or data.count > 0 or not data.next
                $("#employee-load-more-first-loads").remove()

            if !isSearchResult
                #Show warning alerts "employees not found"
                if Object.keys(shownFirstWorkersId).length == 0
                    if not data.results or data.count == 0
                        thisContext.showNotFoundAlert()
            else
                if not data.results or data.count == 0
                    thisContext.showNotFoundAlert()

            for element in data.results
                if !isSearchResult
                    if not shownFirstWorkersId[element.id]
                        shownFirstWorkersId[element.id] = {
                            self: element,
                            subordinates: {}
                        }
                        thisContext.appendElementToDOM ".container-workers", element
                    
                        #Initialization show subordinates(second hierarchy)
                        thisContext.showSecondHierarchy element.id, null, thisContext.secondCount                
                else
                    # Show search results
                    thisContext.appendElementToDOM ".container-workers", element, "search-result" 
                    #thisContext.showSecondHierarchy element.id, null, thisContext.secondCount

            if data.next
                $(".container-workers").append(appendElementLoadMore "first-loads")
                $("#employee-load-more-first-loads").find("a").click (e) ->
                    thisContext.showFirstHierarchy count, thisContext.getLocationPathname(data.next), isSearchResult


    showSecondHierarchy: (elementID, urlNext, count, doUseGlobalArray=true) ->
        sorted = encodeURIComponent($('#select-sorted-by').val())
        url = urlNext or "/employee/#{elementID}/subordinates/?limit=#{count}&sorted=#{sorted}"
        thisContext = this

        @getEmployee url, (data, textStatus, jqXHR) ->
            if data.results or data.count > 0 or not data.next
                $("#employee-load-more-#{elementID}").remove()
            
            # Append employees to chief
            for employee in data.results
                if doUseGlobalArray
                    if not shownFirstWorkersId[employee.chief].subordinates[employee.id]
                        shownFirstWorkersId[employee.chief].subordinates[employee.id] = employee
                        thisContext.appendElementToDOM "#employee-id-#{employee.chief}", employee
                else
                    thisContext.appendElementToDOM "#employee-id-#{elementID}", employee

            if data.next
                $("#employee-id-#{elementID}").append(appendElementLoadMore elementID)
                $("#employee-load-more-#{elementID}").find("a").click (e) ->
                    thisContext.showSecondHierarchy e.target.id, thisContext.getLocationPathname(data.next), thisContext.secondCount, doUseGlobalArray


    hideAllEmployeesInContainer: () ->
        for element in Object.keys(shownFirstWorkersId)
            $("#employee-id-#{element}").css(display: "none")
        $("#employee-load-more-first-loads").css(display: "none")

    showAllEmployeesInContainer: () ->
        @clearContainer()

        for element in Object.keys(shownFirstWorkersId)
            $("#employee-id-#{element}").css(display: "block")
        $("#employee-load-more-first-loads").css(display: "block")


    showNotFoundAlert: () ->
        @clearContainer()

        $('#not-found-employees-warning').css(display: "block")


    hideNotFoundAlert: () ->
        $('#not-found-employees-warning').css(display: "none")

    showErrorAlert: (errorText) ->
        @clearContainer()

        $('#alert_server_error').css(display: "block")
        $('#alert_server_error #error_message').text(errorText)


    hideErrorAlert: () ->
        $('#alert_server_error').css(display: "none")

    removeSearchResults: () ->
        $('[id^="employee-search-result-"]').remove()

    clearContainer: () ->
        # Remove search results and hide all components
        @removeSearchResults()
        @hideNotFoundAlert()
        @hideErrorAlert()
        @hideAllEmployeesInContainer()

    removeEmployees: () ->
        for element in Object.keys(shownFirstWorkersId)
            $("#employee-id-#{element}").remove()

        shownFirstWorkersId = {}

    initEmployees: () ->
        @showFirstHierarchy @firstCount

    getListWorkers: () ->
        return shownFirstWorkersId


# ___________________________ PopUpWindowManager _____________________________ CLASS __
# -------------------------------------------------------------------------------------
class PopUpWindowManager

    mainContainer = "#pop-up-container"
    closePopUpArea = "#{mainContainer} #backgroud-close-block"

    errorBlock = "#{mainContainer} #error-pop-up-block"
    employeeBlock = "#{mainContainer} #info-employee"
    chiefBlock = "#{mainContainer} #info-chief-employee"
    employeesTreeBlock = "#{mainContainer} #tree-view-employees"

    paddingColEmployee = "#{employeeBlock} > .padding-col-employee"


    constructor: () ->
        thisContext = this
        $(closePopUpArea).click () ->
            # If clicked on the background of the popup
            thisContext.hide()


    hide: () ->
        $(mainContainer).css display: "none"
        $(employeeBlock).css display: "none"
        $(chiefBlock).css display: "none"
        $(employeesTreeBlock).css display: "none"
        $(errorBlock).css display: "none"


    show: (employeeId) ->
        thisContext = this
        request = $.ajax 
            url: "/employee/#{employeeId}/"
            type: "GET"

        request.done (data, textStatus, jqXHR) ->
            $(mainContainer).css display: "block"

            if jqXHR.status == 200
                #show employee
                thisContext._showEmployee(data)
                thisContext._showEmployeesTree data.id
                
                if data.chief
                    thisContext._showChief(data.chief)
                    $(paddingColEmployee).css display: "block"
                else
                    # Hide padding employee
                    $(paddingColEmployee).css display: "none"
            else
                #show error

        request.fail (jqXHR, textStatus, errorThrown) ->
            #error request AJAX
            #console.log errorThrown
            $(mainContainer).css display: "block"
            thisContext.showError()


    showError: (textError="Виникла помилка. Спробуйте ще раз") ->
        element = $(errorBlock)
        element.find("p").text(textError)
        element.css display:"flex"


    _showEmployee: (data) ->
        element = $(employeeBlock)
        element.css display: "flex"
        @_appendData element, data


    _showChief: (employeeId) ->
        thisContext = this
        request = $.ajax 
            url: "/employee/#{employeeId}/"
            type: "GET"

        request.done (data, textStatus, jqXHR) ->
            if jqXHR.status == 200
                element = $(chiefBlock)
                element.css display: "flex"
                thisContext._appendData element, data

        request.fail (jqXHR, textStatus, errorThrown) ->
            #error request AJAX
            thisContext.showError "Не вдалося завантажити начальника робітника."


    _showEmployeesTree: (employeeId) ->
        thisContext = this
        request = $.ajax 
            url: "/employee/#{employeeId}/get_tree/"
            type: "GET"

        request.done (data, textStatus, jqXHR) ->
            if jqXHR.status == 200 and data.employee

                containerTree = $("#{employeesTreeBlock} #tree-detail-container")

                preDomTreeHtml = ""
                firstCall = true

                getEmpTree = (employeeData) ->
                    if employeeData.self
                        if employeeData.self.subordinate_count >= 1
                            if firstCall
                                pCS = "<li><a>#{employeeData.self.subordinate_count}</a></li>"
                            else
                                if employeeData.self.subordinate_count > 1
                                    pCS = "<li><a>Та ще #{employeeData.self.subordinate_count - 1}</a></li>"
                                else
                                    pCS = ""
                        else
                            pCS = ""

                        firstCall = false

                        ulAppend = if preDomTreeHtml == "" and pCS == "" then "" else """
                                <ul>
                                    #{preDomTreeHtml}
                                    #{pCS}
                                </ul>
                            """

                        preDomTreeHtml = """
                            <li>
                                <a>#{employeeData.self.name}</a>
                                #{ulAppend}
                            </li>
                            """

                    if employeeData.employee
                        getEmpTree employeeData.employee

                getEmpTree data
                containerTree.html "<ul>#{preDomTreeHtml}</ul>"

                element = $(employeesTreeBlock)
                element.css display: "flex"


    _appendData: (element, data) ->
        element.find("h4").text(data.name)
        element.find("h6").text(data.work_position)
        element.find("p").text(data.date_join)
        element.find("h3").text(data.wage)



# _________________________________ MAIN _____________________________________ EVENTS __
# --------------------------------------------------------------------------------------

$(document).ready ->
    managerPopUp = new PopUpWindowManager
    managerEmployees = new AJAXEmployeesManager 40, 10, managerPopUp
    managerEmployees.initEmployees()


    delay = (callback, ms=800) ->
        timer = 0;
        return () ->
            context = this
            args = arguments
            clearTimeout timer

            callbackRet = () ->
                callback.apply context, args

            timer = setTimeout callbackRet, ms || 0


    appendSpinner = (inputId) ->
        $(inputId).each () ->
            $(this).attr "class", "#{$(this).attr 'class'} width-input-append-spinner"
        $('<i class="fas fa-cog fa-spin"></i>').insertAfter inputId


    removeSpinner = (inputId) ->
        if $(inputId).next().is("i.fa-spin")
            $(inputId).removeClass(
                "width-input-append-spinner"
                ).next().remove()


    replaceSpaces = (element) ->
        resultString = ''
        for i in element.split(' ')
            if i != ''
                resultString += i + ' '
        return resultString.slice(0, -1)


    normalizeSendData = (data) ->
        if "|" in data
            resultData = data.split("|")

            for searchStrElem, index in resultData
                resultData[index] = replaceSpaces(searchStrElem)

            return resultData
        else
            return [replaceSpaces(data)]


    sendSearchBy = () ->
        byNameData = normalizeSendData($('#search-by-name-field').val())
        byWorkPositionData = normalizeSendData($('#search-by-work-position-field').val())
        byWageData = normalizeSendData($('#search-by-wage-field').val())

        requestSearchFieldsData = ''
        
        if byNameData.length > 0 and byNameData[0] != ''
            requestSearchFieldsData += 'name__icontains=' + byNameData.join() + '|'
    
        if byWorkPositionData.length > 0 and byWorkPositionData[0] != ''
            requestSearchFieldsData += 'work_position__icontains=' + byWorkPositionData.join() + '|'

        if byWageData.length > 0 and byWageData[0] != ''
            requestSearchFieldsData += 'wage=' + byWageData.join() + '|'
        
        if requestSearchFieldsData.length == 0
            managerEmployees.showAllEmployeesInContainer()
            return false

        requestSearchFieldsData.slice(0, -1)

        requestData = encodeURIComponent(requestSearchFieldsData)
        limit = 20

        sorted = encodeURIComponent($('#select-sorted-by').val())
        url = "/employee/search/?limit=#{limit}&data=#{requestData}&sorted=#{sorted}"
        managerEmployees.clearContainer()
        managerEmployees.showFirstHierarchy(20, url, true)
        return true


    functionSearchBy = (e) ->
        data = e.currentTarget.value

        appendSpinner(e.currentTarget)
        
        sendSearchBy()

        functionTimeout = () ->
            removeSpinner(e.currentTarget)
        setTimeout functionTimeout, 1000


    functionSortedBy = (e) ->
        #console.log this.value
        #console.log $('#select-sorted-by').val()

        if sendSearchBy()
            return

        managerEmployees.clearContainer()
        managerEmployees.removeEmployees()
        managerEmployees.initEmployees()







    $('#search-by-name-field').keyup delay functionSearchBy #Search by name
    $('#search-by-work-position-field').keyup delay functionSearchBy #Search by work position
    $('#search-by-wage-field').keyup delay functionSearchBy #Search by wage
    
    $('#select-sorted-by').change functionSortedBy #Select sorted by