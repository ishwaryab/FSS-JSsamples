
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!--  
 * Project Id :
 * 
 * Class Name: inputFileConfiguration.jsp
 * 
 * Purpose : To Add new file definition.
 * 
 * Author : Ishwarya B
  
 * Created Date : 29/12/2016
 * 
 * Modified By : 
 * 
 * Modified Date:
 * 
 * Modify Reason: 
 -->

 <script type = "text/javascript" src = "${pageContext.request.contextPath}/resources/js/inputFileConfig.js"></script>
	<script type="text/javascript">
 var popupWindow=null;
 $(document).ready(function(){
	
	//file name button is clicked
		$("#fileNameDtlsButton").click(function(){
			
 			var fileNameResult = true;
			
			var fileName = $.trim($("#fileName").val());
// 			var fileShortName = $.trim($("#fileShortName").val());
			var fileDescription = $.trim($("#fileDescription").val());
			var fileType = $.trim($("#fileType").val());
			var dupCheckOnFile = $.trim($("#duplicateCheckOnFileName").val());
		//	var nameConventionCheck = $.trim($("#fileNameConventionApplicable").val());
			var dependencyFileName = $.trim($("#dependencyFileName").val());
			var fileNameOnSelect = $.trim($("#fileNameOnSelect").val());
			if(fileName == null || fileName == ""){					
				$("#fileNameErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterFileName" />');
				fileNameResult = false;
			}
			
			if(fileDescription == null || fileDescription == ""){
				$("#fileDescriptionErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterFileDescription" />');
				$("#fileDescriptionErrorMsg").show();		//		Added by Anil Kumar D for Mantis Id : 14019
				fileNameResult = false;
			}
			
				//var dependencyFileName = $("#dependencyFileName").val();
				var depStatus  = ($('[name="dependency"]').is(':checked'));
				//alert(depStatus);
				if(depStatus){
					//alert("tst"+dependencyFileName);
				  if(dependencyFileName == null || dependencyFileName == ""){
					$("#dependencyFileNameErrorMsg").html("Please Select the Dependency File");
					$("#dependencyFileNameErrorMsg").show();
					fileNameResult = false;
				  }else{
					  $("#dependencyFileNameErrorMsg").html("");
						$("#dependencyFileNameErrorMsg").hide();
				  }
				}
			if(fileType == null || fileType == ""){
				$("#fileTypeErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectFileType" />');
				fileNameResult = false;
			}else{
				if(fileType == "D"){
					if($("#delimiter").val() == ""){
						fileNameResult = false;
						$("#delimiterErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectDelimiter"/> ');
					}else{
						$("#delimiterErrorMsg").html("");
					}
				}
				//added by Nancy for xml file 
				 var filePath = $.trim($("#xsdFileName").val());
					var fileType = $.trim($("#fileType").val());
				 
					if(fileType == 'X'&&  filePath == ""  ){
							fileNameResult = false;
							 $("#xsdFileNameErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectXSDfileName"/> '); 
							 $("#xsdFileNameErrorMsg").show(); 
						} 
						
				$("#fileTypeErrorMsg").html("");
			}
			
			if(dupCheckOnFile == null || dupCheckOnFile == ""){
				$("#dupCheckOnFileNameErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectDuplicateCheckOnFileName" />');
				fileNameResult = false;
			}else{
				$("#dupCheckOnFileNameErrorMsg").html("");
			}
			
					
// 			var fileLocation = $("input[name = 'fileLocation']:checked").val();
			var fileLocation = ($('[name="fileLocation"]').is(':checked'));
			var filePath = $.trim($("#filePathLocation").val());
			var ftpFilePath =  $.trim($("#ftpFilePath").val());
			//Added by nancy for file Location(radio) Validation
			if(!fileLocation){
					fileNameResult = false;
					$("#fileLocationErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileHeader.Validation.selectFileLoc" />');
				}else{
					$("#fileLocationErrorMsg").html("");
				}
				var fileLocationFtp = $("#fileLocationFtp").val();
			
			    if(fileLocationFtp == 'F'){
				var ftpServerName = $("#ftpServerName").val();
				if(ftpServerName == ""){
					fileNameResult = false;
					$("#ftpServerNameErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileHeader.Validation.selectftpservername" />');
				}else{
					$("#ftpServerNameErrorMsg").html("");
				}
				var ftpFilePath = $("#ftpFilePath").val();
				if(ftpFilePath == ""){
					fileNameResult = false;
					$("#ftpFilePathErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileHeader.Validation.enterftpfilepath" />');
				}else{
					var pathResult = true;
					//alert("in elese")
					if(navigator.platform.charAt(0) == "W") {
						if((ftpFilePath.charAt(0) != "\\" && ftpFilePath.charAt(1) != "\\") && (ftpFilePath.charAt(0) != "/" && ftpFilePath.charAt(1) != "/")) {
							if(!ftpFilePath.charAt(0).match(/^[a-zA-z]/))   {
								//alert("Enter Valid location");
								fileNameResult = false;
								pathResult = false;
							}
							if(ftpFilePath.charAt(1) == "" ||!ftpFilePath.charAt(1).match(/^[:]/) || !ftpFilePath.charAt(2).match(/^[\/\\]/)) {
								//alert("Enter Valid location");
								fileNameResult = false;
								pathResult = false;
							}
						}
					} else  {
						if(ftpFilePath.charAt(0) != "/") {
							//alert("Enter Valid location");
							fileNameResult = false;
							pathResult = false;
						}
						if(ftpFilePath.charAt(0) == "/" && ftpFilePath.charAt(1) == "/") {
							//alert("Enter Valid location");
							fileNameResult = false;
							pathResult = false;
						}
					}
					
					if(!pathResult){
						$("#ftpFilePathErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidFilePath" />');
						fileNameResult = false;
					}else{
						$("#ftpFilePathErrorMsg").html("");
					
					}
				}
				}
			
// 			if(fileLocation == 'L' && filePath == ""){//commented by nancy on 27-04-16 for FTP
			if(filePath == ""){
				fileNameResult = false;
				$("#filePathErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterFileLocalPath" />');
			}else{
				var pathResult = true;
				//alert("in elese")
				if(navigator.platform.charAt(0) == "W") {
					if((filePath.charAt(0) != "\\" && filePath.charAt(1) != "\\") && (filePath.charAt(0) != "/" && filePath.charAt(1) != "/")) {
						if(!filePath.charAt(0).match(/^[a-zA-z]/))   {
							//alert("Enter Valid location");
							fileNameResult = false;
							pathResult = false;
						}
						if(filePath.charAt(1) == "" ||!filePath.charAt(1).match(/^[:]/) || !filePath.charAt(2).match(/^[\/\\]/)) {
							//alert("Enter Valid location");
							fileNameResult = false;
							pathResult = false;
						}
					}
				} else  {
					if(filePath.charAt(0) != "/") {
						//alert("Enter Valid location");
						fileNameResult = false;
						pathResult = false;
					}
					if(filePath.charAt(0) == "/" && filePath.charAt(1) == "/") {
						//alert("Enter Valid location");
						fileNameResult = false;
						pathResult = false;
					}
				}
				
				if(!pathResult){
					$("#filePathErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidFilePath" />');
					fileNameResult = false;
				}else{
					$("#filePathErrorMsg").html("");
				}
			}
			
		 //added to fix mantis issue id 14111
			 if( parseInt($.trim($("#fileNameMaxLength").val())) == 0 ) {
				 fileNameResult = false;
					$("#fileNameMaxLengthErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.shouldBeMoreThan1" />');
					$("#fileNameMaxLengthErrorMsg").show();
			 } 
			//file name availability
			var fileNameErrorMsg = $.trim($("#fileNameErrorMsg").html());
			//alert(" file name error is : "+fileNameErrorMsg)
			
			if(fileNameErrorMsg != ""){
				fileNameResult = false;
			}
			
			//file Description name availability
			var fileDescription = $.trim($("#fileDescriptionErrorMsg").val());
			if(fileDescription != ""){
				fileNameResult = false;
			}
			
			
			
			if( fileNameResult ){
				//alert("tab 1");
				var nextId = $(this).parents('.tab-pane').next().attr("id");
					//alert(nextId);
				$(".inactive-tab-wizard").find('.'+nextId).tab('show');
				//	$(".inactive-tab-wizard").find('.tab-pane').css({"position":"absolute","top":"-1000px"});
					$(".inactive-tab-wizard").find('.tab-pane').removeClass("fade in active");
					$(".inactive-tab-wizard").find('#'+nextId).removeAttr('style').addClass("fade in active");
				
			}
		});
	
		//File Location clicks
		 $(".filelocationDiv .prettyradio").click(function(){
			var val = $(this).find("input[name='fileLocation']").val();
				if(val == 'F'){
					$("#fileServerDiv").show();
					$("#filePathLocation").val("");
					$("#filePathLocationDiv").hide();
					$("#filePathErrorMsg").html("");
					
					//need to display ftp source and destination path
					$("#ftpDiv").show();
				} else {
					$("#fileServerDiv").hide();
					$("#ftpDiv").hide();
					$("#filePathLocationDiv").show();
				}
		}); 
		//fileLocationLocal
		
		//Ajax call to check file name availability
		$( "#fileName" ).change(function() {
			
			var fileName = $.trim($("#fileName").val())	
			
			if(fileName != "" ){
				$.ajax({
				    url: "checkFileNameAvailability.rcn?fileName="+fileName, 
				    type: 'POST', 
				    dataType: 'json', 
				    contentType: 'application/json',
				    mimeType: 'application/json',
				    success: function(data) { 
				        ////alert(data);
				        $("#fileNameErrorMsg").html(data);
				    },
				    error:function(data,status,er) { 
				        ////alert("error: "+data+" status: "+status+" er:"+er);
				    }
				});
			}else{
				$( "#fileNameErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterFileName" />');
			}
		});
		
		$("#fileDescription").change(function(){
			$("#fileDescriptionErrorMsg").html("");
		});
		
		$("#fileLocationLocal").change(function(){//nancy
			$("#fileLocationErrorMsg").html("");
		});
		$("#fileLocationFtp").change(function(){//nancy
			$("#fileLocationErrorMsg").html("");
		});
		
		$("#ftpServerName").change(function() {//nancy
			var fileLocationFtp = $("#fileLocationFtp").val();
			if(fileLocationFtp == 'F'){
				var ftpServerName = $("#ftpServerName").val();
				if(ftpServerName == ""){
					$("#ftpServerNameErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileHeader.Validation.selectftpservername" />');
				}else{
					$("#ftpServerNameErrorMsg").html("");
				}
			}
		});
		
		$("#ftpFilePath").keypress(function() {//nancy
			var fileLocationFtp = $("#fileLocationFtp").val();
			if(fileLocationFtp == 'F'){
				var ftpFilePath = $("#ftpFilePath").val();
				if(ftpFilePath == ""){
					$("#ftpFilePathErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileHeader.Validation.enterftpfilepath" />');
				}else{
					$("#ftpFilePathErrorMsg").html("");
				}
			}
		});
		
		
		//Ajax call to check file short name availability
		$( "#fileShortName" ).change(function() {
			
			var fileShortName = $.trim($("#fileShortName").val());
			//alert(fileShortName);
			
			if(fileShortName != "" ){
				$.ajax({
				    url: "checkFileShortNameAvailability.rcn?fileShortName="+fileShortName, 
				    type: 'POST', 
				    dataType: 'json', 
				    contentType: 'application/json',
				    mimeType: 'application/json',
				    success: function(data) { 
				        //alert(data);
				        $("#fileShortNameErrorMsg").html(data);
				    },
				    error:function(data,status,er) { 
				        //alert("error: "+data+" status: "+status+" er:"+er);
				    }
				});
			}else{
				$( "#fileShortNameErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterFileShortName" />');
			}
		});
		
		//to allow only numeric values(Numeric Check) for File Name Max Length and Header Tag Count and noOfLinesBetweenDr
				$("#fileNameMaxLength, #headerDataElement, #dataRecordsBetweenHeaders, #headerBlockSize, "+
						" #footerLength, #noOfLinesBetweenDr, "+
						" #headerKeyCount, #noOfLines, #recordCountPerLine, #noOfConstant").keypress(function(e){
							
// 	        keycode =8 backspace
// 	        keycode =13 Enter
// 	        keycode =9 Tab
// 	        keycode =37 left arrow
// 	        keyCode =39 right arrow
//			keyCode = 46 Delete
			//Added by Anil Kumar D for Mantis Id : 14017
			var ret ;
			var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
			if(keyCode == 0) {
				ret = true;
			} else {
				// Key code 39(for Single Qoute) is removed by Anil Kumar D for Mantis Id : 14088
				 ret = ((keyCode >= 48 && keyCode <= 57) || (keyCode == 8)||(keyCode == 13)||(keyCode == 9));
			}
			
	        if(!ret)
	        	$("#"+this.id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidNumber" />');
	        else
	        	$("#"+this.id+"ErrorMsg").html("");
			return ret;
		});
		
		//to allow only numeric (excluding ZERO) for Multiple Header Data Count and recordCountPerLine
		$("#controlTagCount").keypress(function(e){
	        var specialKeys = new Array();
	        specialKeys.push(8); //Backspace
	        specialKeys.push(13); //Enter
	        specialKeys.push(9); //tab		//Added by Anil Kumar D for Mantis id : 14108
	        specialKeys.push(); //zero
			var keyCode = e.which ? e.which : e.keyCode
     		var ret = ((keyCode >= 49 && keyCode <= 57) || $.inArray(keyCode, specialKeys) != -1);

	        if(!ret)
				$("#"+this.id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.numericsWithOutZero" />');
	        else
	        	$("#"+this.id+"ErrorMsg").html("");
			return ret;
		});
		$("#fileBeginWith").attr("disabled", "disabled");
		
		
		
		$("#fileNameConventionFormat").change(function(){
			var val = $(this).val();
			if(val != null &&  val!= ""){
				
				$("#fileNameConventionFormatErrorMsg").html("");
			}
		});
		
	
		//added by nancy for previous button validation
			 $('#numberOfFormat').focus(function() {
			    prev_val = $(this).val();
			}).change(function(){
				
				$("#hiddenActionDiv").empty();
				 $("#footerAvailable").val("");
				 $("#footerAvailable").attr("disabled",false);
				 $("#footerType").val("");
				 $("#controlTagCount").val("");
				 $("#footerTypeErrorMsg").html('');
				 $("#footerTypeErrorMsg").hide();
				 $("#controlTagCount").val("");
				 $("#dynamicFooterDiv").hide(); 
			
		
 		});	
		 $('#multiFormatDataSupport').focus(function() {
			    prev_val = $(this).val();
			}).change(function(){
				
				$("#hiddenActionDiv").empty();
				 $("#footerAvailable").val("");
				 $("#footerAvailable").attr("disabled",false);
				 $("#footerType").val("");
				 $("#controlTagCount").val("");
				 $("#footerTypeErrorMsg").html('');
				 $("#footerTypeErrorMsg").hide();
				 $("#controlTagCount").val("");
				 $("#dynamicFooterDiv").hide(); 
			
		
		});
		
		// when delimiter is selected.
		$("#delimiter").change(function(){
			$("#fileTypeErrorMsg, #delimiterErrorMsg").html("");
		});
		
		$("#filePathLocation").change(function(){
			var val = $(this).val();
			if(val != null &&  val!= ""){
				
				$("#filePathErrorMsg").html("");
			}
		
		});
		//added by nancy for xml
		$("#xsdFileName").change(function(){
			var val = $(this).val();
			if(val != null &&  val!= ""){
				
				$("#xsdFileNameErrorMsg").html("");
			}
			
		});
		//added by nancy for dependency
		 $("#dependencyFileName").change(function(){
			var val = $(this).val();
			if(val != null &&  val!= ""){
				
				$("#dependencyFileNameErrorMsg").html("");
			}
			
		}); 
// 		to block space in file path added for Banu requirement
		$("#filePathLocation").keypress(function(e){
			var keyCode = e.which ? e.which : e.keyCode;
// 			keycode = 32 space
			if(keyCode == 32){
				return false;
			}
		});
		
//File Validation ends

//Header Validations Start  

		$("#fileHeaderAvailable").change(function(){
			//alert("in file header available");
			var fileType = $("#fileType").val();  //added by nancy
			var fileHeaderAvailable = $("#fileHeaderAvailable").val();
			
			if(fileHeaderAvailable == 'Y'){
				$("#headerWithDr ").removeAttr("disabled");
				
				$("#headerKeyCount, #headerBlockSize, #dataRecordsBetweenHeaders").attr("readonly", false);
				
				$("#fileHeaderAvailableErrorMsg").html("");
				if( fileType == 'X'){                                //added by nancy
					$("#headerKeyCount").val(1);
					$("#headerKeyCount").attr("readonly", true);
					$("#headerWithDr").val('N');
					$("#headerWithDr").attr('disabled' , true);
// 					$("#dynamicDataLineDiv").show();
					fn_headerDetailsGridFunction(1);
					$("#headerKeyFromPosition-0").attr("readonly",true);
					$("#headerKeyToPosition-0").attr("readonly",true);
					$("#headerBeginsCheckApplicable-0").val('N');
					$("#headerBeginsCheckApplicable-0").attr('disabled' , 'disabled');
					//$("#fileHeaderBeginsWithConst-0").attr("readonly", false);
					//$("#headerBeginsCheckApplicable-0").attr("disabled","disabled");
					$("#fileHeaderBeginsWithConst-0").attr("readonly",false);
					$("#fileHeaderDuplicateValue-0").val('Y');
					$("#fileHeaderDuplicateValueTextBox-0").val("Y");
					$("#fileHeaderDuplicateValue-0").attr('checked' , 'checked');
					$("#fileHeaderDuplicateValue-0").attr('disabled' , true);
					$("#headerSequenceCheckApplicable-0").attr('disabled' , true);
				}
			
			}else if(fileHeaderAvailable == 'N' || fileHeaderAvailable == ''){
				//to pur default values.
				$("#headerKeyCount, #dataRecordsBetweenHeaders, #headerBlockSize, #headerWithDr").val("");
				
				//to remove error messages
				$("#fileHeaderAvailableErrorMsg, #headerKeyCountErrorMsg, #dataRecordsBetweenHeadersErrorMsg, "+
							" #headerBlockSizeErrorMsg, #headerWithDrErrorMsg ").html("");
				
				//to disable all input types
				$("#headerWithDr").attr("disabled", "disabled");
				
				$("#headerKeyCount, #headerBlockSize, #dataRecordsBetweenHeaders").attr("readonly", true);
				
				$("#dynamicDataLineDiv").hide();
				
				if(fileHeaderAvailable == '') {
					$("#fileHeaderAvailableErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.fileHeaderAvailable" />');
				}
				
			}else{
				$("#fileHeaderAvailableErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.fileHeaderAvailable" />');
			}
		});
		
			
		$("#headerWithDr").change(function(){
			
			////alert("in headerWithDr");
			var headerWithDr = $(this).val();
			if(headerWithDr == ""){
				$("#headerWithDrErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectHeaderWithDr" />');
				
			}else{
				$("#headerWithDrErrorMsg").html("");
			}
		});
		
		$(document).find("select[name^='headerDataType']").on('change', function(){
			////alert("hi ");
		});
		
		//When header Next button clicked. 
		$("#headerDetailsBtnId").click(function(){
			
			////alert("button clicked");
			var fileHeaderAvailable = $("#fileHeaderAvailable").val();
			var headerResult = true;
			
			if(fileHeaderAvailable == ""){ // file Header is not selected
				$("#fileHeaderAvailableErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.fileHeaderAvailable" />');
				headerResult = false;
			}else if(fileHeaderAvailable == 'Y'){
				var headerWithDr = $.trim($("#headerWithDr").val());
				if(headerWithDr == ""){
					headerResult = false;
					$("#headerWithDrErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterHeaderWithDr" />');
				}
				
						
							var headerDataCount = $.trim($("#headerKeyCount").val());
	    					
							if(headerDataCount == null || headerDataCount == ""){
	    						headerResult = false;
	    						$("#headerKeyCountErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterMultipleHeaderDataCount"/>');
	    						$("#headerKeyCountErrorMsg").show();
	    					}else if($.isNumeric($("#headerKeyCount").val()) && parseInt($("#headerKeyCount").val()) <= 0){
	    						headerResult = false;
	    						$("#headerKeyCountErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.shouldBeMoreThan1" />');
	    						$("#headerKeyCountErrorMsg").show();
	    					}else{
	    						$("#headerKeyCountErrorMsg").html("");
	    						$("#headerKeyCountErrorMsg").hide();
	    					//for
	    					var count = $("#headerKeyCount").val();
	        			
	        			var fileType = $("#fileType").val();
	        			
	        			for ( var i = 0; i < count; i++ ) {	        					        		
	    					if(fileType != 'X')	{           //added by nancy to remove validation for xml
		        				if($("#headerKeyFromPosition-"+i).val() == ''){
		        					$("#headerKeyFromPosition-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.headerFromPosition" />');
		        					$("#headerKeyFromPosition-"+i+"ErrorMsg").show();
		        					headerResult = false;
		        				} else {
		        					$("#headerKeyFromPosition-"+i+"ErrorMsg").html('');
		        					$("#headerKeyFromPosition-"+i+"ErrorMsg").hide();
		        				}
		        				if($("#headerKeyToPosition-"+i).val() == ''){
		        					headerResult = false;
		        					$("#headerKeyToPosition-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.headerToPosition" />');
		        					$("#headerKeyToPosition-"+i+"ErrorMsg").show();
		        				} else{
		        					if ($("#headerKeyToPosition-"+i+"ErrorMsg").html() != '') {
				   						headerResult = false;
				   					} else {
				   						$("#headerKeyToPosition-"+i+"ErrorMsg").html('');	
				   						$("#headerKeyToPosition-"+i+"ErrorMsg").hide();
				   					}
		        				}
		        				
		        				// From to Validation
		        				if($("#headerKeyFromPosition-"+i).val() != '' && $("#headerKeyToPosition-"+i).val() != ''){
		        					var fromPosition = parseInt($("#headerKeyFromPosition-"+i).val()); 
		        					var toPosition =  parseInt($("#headerKeyToPosition-"+i).val());
		        					
		        					if(toPosition < fromPosition ){
		        						headerResult = false;
		        						$("#headerKeyToPosition-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.lesserToPosition" />');
		        						$("#headerKeyToPosition-"+i+"ErrorMsg").show();
		        					} else {
		        						$("#headerKeyToPosition-"+i+"ErrorMsg").html("");
		        						$("#headerKeyToPosition-"+i+"ErrorMsg").hide();
		        					}
		        				}	      
	    					}				
	        				 //added to fix mantis issue id 14111
		       				 if( parseInt( $.trim( $("#headerKeyFromPosition-"+i).val() ) ) == 0 ) {
		       					headerResult = false;
		       					$("#headerKeyFromPosition-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.shouldBeMoreThan1" />');
		       					$("#headerKeyFromPosition-"+i+"ErrorMsg").show();
	    					}
		       				if( parseInt( $.trim( $("#headerKeyToPosition-"+i).val() ) ) == 0 ) {
		       					headerResult = false;
		       					$("#headerKeyToPosition-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.shouldBeMoreThan1" />');
		       					$("#headerKeyToPosition-"+i+"ErrorMsg").show();
		       				 } 
	        				if($("#fileHeaderDataType-"+i).val() == ''){
	        					headerResult = false;
	        					$("#fileHeaderDataType-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.headerDataType" />');
	        					$("#fileHeaderDataType-"+i+"ErrorMsg").show();
	        				}
	        				else{
	        					$("#fileHeaderDataType-"+i+"ErrorMsg").html('');
	        					$("#fileHeaderDataType-"+i+"ErrorMsg").hide();
	        				}
	        				if($("#fileHeaderDataType-"+i).val() != '' && $("#fileHeaderDataFormat-"+i).val() == ''){
	        					headerResult = false;
	        					$("#fileHeaderDataFormat-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.headerDataFormat" />');
	        					$("#fileHeaderDataFormat-"+i+"ErrorMsg").show();
	        				}
	        				else{
	        					$("#fileHeaderDataFormat-"+i+"ErrorMsg").html('');
	        					$("#fileHeaderDataFormat-"+i+"ErrorMsg").hide();
	        				}
	        				if($("#fileHeaderLinePosition-"+i).val() == ''){
	        					headerResult = false;
	        					$("#fileHeaderLinePosition-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.headerLinePosition" />');
	        					$("#fileHeaderLinePosition-"+i+"ErrorMsg").show();
	        				}
	        				else{
	        					$("#fileHeaderLinePosition-"+i+"ErrorMsg").html('');
	        					$("#fileHeaderLinePosition-"+i+"ErrorMsg").hide();
	        				}
	        				 //added to fix mantis issue id 14111
	        				if( parseInt( $.trim( $("#fileHeaderLinePosition-"+i).val() ) ) == 0 ) {
	        					headerResult = false;
	        					$("#fileHeaderLinePosition-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.shouldBeMoreThan1" />');
	        					$("#fileHeaderLinePosition-"+i+"ErrorMsg").show();
	        				}
	        				if($("#headerBeginsCheckApplicable-"+i).val() == 'Y'){
	        					if($("#fileHeaderBeginsWithConst-"+i).val() == ''){
	        						headerResult = false;
	        						$("#fileHeaderBeginsWithConst-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.headerBeginsConstant" />');
	        						$("#fileHeaderBeginsWithConst-"+i+"ErrorMsg").show();
	        					}
	        					else{
	        						$("#fileHeaderBeginsWithConst-"+i+"ErrorMsg").html('');
	        						$("#fileHeaderBeginsWithConst-"+i+"ErrorMsg").hide();
	        					}
	        					if($("#fileHeaderDuplicateValue-"+i).val() == 'N' && $("#headerSequenceCheckApplicable-"+i).val() == 'N' ){
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").html('');
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").hide();
	        					}
	        					else{
	        						headerResult = false;
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.checkShouldNotApply" />');
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").show();
	        					}
	        					
	        					//Added to check data type is not date for begin check yes
	        					if($("#fileHeaderDataType-"+i).val() == '3') {
	        						$("#fileHeaderDataType-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidDataTypeForStartCheck"/>');
	        						$("#fileHeaderDataType-"+i+"ErrorMsg").show();
	        					} else {
	        						if($("#fileHeaderDataType-"+i).val() != ''){
	        							$("#fileHeaderDataType-"+i+"ErrorMsg").html("");
		        						$("#fileHeaderDataType-"+i+"ErrorMsg").hide();	
	        						}
	        					}
	        				}
	        				else if($("#headerBeginsCheckApplicable-"+i).val() == 'N'){
	        					if($("#fileHeaderDuplicateValue-"+i).val() == 'N' &&  $("#headerSequenceCheckApplicable-"+i).val() == 'N' ){
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.oneShouldBeChecked" />');
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").show();
	        						headerResult = false;
	        					}
	        					else{
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").html('');
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").hide();
	        					} 
	        					if($("#fileHeaderDuplicateValue-"+i).val() == 'Y' && $("#headerSequenceCheckApplicable-"+i).val() == 'Y' ){
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectOneNotBoth" />');
	        						$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").show();
	        						headerResult = false;
	        					}
	        				}else if($("#headerBeginsCheckApplicable-"+i).val() == 'D'){
	        				
	        				}else{
	        					headerResult = false;
	        					$("#headerBeginsCheckApplicable-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.headerBeginsCheck" />');
	        					$("#headerBeginsCheckApplicable-"+i+"ErrorMsg").show();
	        				}
	        				
	    					//added by nancy
	        				if(fileType == 'X')	{
	        					if($.trim($("#fileHeaderBeginsWithConst-"+i).val()) == ''){
	        						headerResult = false;
	        						$("#fileHeaderBeginsWithConst-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.headerBeginsConstant" />');
	        						$("#fileHeaderBeginsWithConst-"+i+"ErrorMsg").show();
	        					}
	        					else{
	        						$("#fileHeaderBeginsWithConst-"+i+"ErrorMsg").html('');
	        						$("#fileHeaderBeginsWithConst-"+i+"ErrorMsg").hide();
	        					}
	        				}	
	        			}
	    					
	        			// validation to check only one checkbox is selected
		        			var dupCounter = 0;
	        				var seqCounter = 0;
	        				
						for ( var i = 0; i < count; i++ ) {
							if($("#headerBeginsCheckApplicable-"+i).val() == 'N'){
								
								if($("#fileHeaderDuplicateValue-"+i).val() == 'Y' ){
									dupCounter++;
									if(dupCounter >= 2){
										$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.oneDuplicateCheck" />');
										$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").show();
										headerResult = false;
									} else {
										$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").html("");
										$("#fileHeaderDuplicateValue-"+i+"ErrorMsg").hide();
									}
								}
								
								if($("#headerSequenceCheckApplicable-"+i).val() == 'Y' ){
									seqCounter++;
									if(seqCounter >= 2){
										$("#headerSequenceCheckApplicable-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.oneSequenceCheck" />');
										$("#headerSequenceCheckApplicable-"+i+"ErrorMsg").show();
										headerResult = false;
									} else {
										$("#headerSequenceCheckApplicable-"+i+"ErrorMsg").html("");
										$("#headerSequenceCheckApplicable-"+i+"ErrorMsg").hide();
									}
								}
								
								if($("#headerSequenceCheckApplicable-"+i).val() == 'Y' ){
									if(!($("#fileHeaderDataType-"+i).val() == '3' || $("#fileHeaderDataType-"+i).val() == '')) {
										$("#fileHeaderDataType-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.dataTypeSequenceCheck" />');
										$("#fileHeaderDataType-"+i+"ErrorMsg").show();
										$("#fileHeaderDataFormat-"+i+"ErrorMsg").html("");
										$("#fileHeaderDataFormat-"+i+"ErrorMsg").hide();
										headerResult = false;
									} else {
										if($("#fileHeaderDataType-"+i).val() != ''){
											$("#fileHeaderDataType-"+i+"ErrorMsg").html("");
											$("#fileHeaderDataType-"+i+"ErrorMsg").hide();
										}
									}
								}
								
								if($("#fileHeaderDuplicateValue-"+i).val() == 'Y' ){
									if(!($("#fileHeaderDataType-"+i).val() == '1' || $("#fileHeaderDataType-"+i).val() == '')) {
										$("#fileHeaderDataType-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.dataTypeDuplicateCheck" />');
										$("#fileHeaderDataType-"+i+"ErrorMsg").show();
										$("#fileHeaderDataFormat-"+i+"ErrorMsg").html("");
										$("#fileHeaderDataFormat-"+i+"ErrorMsg").hide();
										headerResult = false;
									} else {
										if($("#fileHeaderDataType-"+i).val() != ''){
											$("#fileHeaderDataType-"+i+"ErrorMsg").html("");
											$("#fileHeaderDataType-"+i+"ErrorMsg").hide();	
										}
									}
								}
							}
						} // for end checkbox validation							        				
	    				}
	    			
    					}
			
			
// 			headerResult = true;		//need to remove.
			if(headerResult ){
				var nextId = $(this).parents('.tab-pane').next().attr("id");
				$(".inactive-tab-wizard").find('.tab-pane').removeClass('in active');
				$(".inactive-tab-wizard").find('.'+nextId).tab('show');
				//$(".inactive-tab-wizard").find('.tab-pane').css({"position":"absolute","top":"-1000px"});
				$(".inactive-tab-wizard").find('#'+nextId).removeAttr("style").addClass('in active');
			}
		});

		//Added by Govardhan to display header fields Based on  Number of Lines...
		$("#headerKeyCount").change(function(e){
			////alert("in on chnage for no of lines: "+$(this).val());
			
			var iteration = $(this).val();
			var output = "";
			if(iteration.trim()==""){
				$("#dynamicDataLineDiv").hide();
			}
			else{
				fn_headerDetailsGridFunction(iteration);
		   }
		});

		
//Header Validation Ends

//Footer Validations Starts mohan raj
		
		$("#footerAvailable").change(function(){
			var val = $(this).val();
		 	  if(val == 'Y'){
				//$("#footerDetailsDiv").find(":input").removeAttr('disabled');
				$("#footerType").removeAttr('disabled');
				 $("#controlTagCount, #footerBeginsConstant, #footerLength").attr("readonly", false);
				$("#footerBeginsConstant, #footerLength").attr("readonly", false);
				$("#footerAvailableErrorMsg").html("");
				
				// to fix delimiter issue in footer tab(5933)
				var fileType = $("#fileType").val();
				if(fileType == 'X'){                           //added by nancy for xml
					//$("#controlTagCount, #footerBeginsConstant, #footerLength").attr("readonly", false);
					$("#footerType").val("D");
					$("#footerType").attr("disabled", "disabled");
				}
				if(fileType == 'F'){
					//alert(" in F ");
					$("#footerType").val("F");
					$("#footerType").attr("disabled", "disabled");
				}
				
			}else if(val ==  'N'){
				$("#footerType, #controlTagCount, #footerBeginsConstant, #footerLength").val("");
				
						$("#controlTagCount, #footerBeginsConstant, #footerLength").attr("readonly", true);
						
						$("#footerType").attr("disabled", "'disabled");
						
						$("#dynamicFooterDiv").hide();
				
				$("#footerAvailableErrorMsg, #controlTagCountErrorMsg, #footerBeginsConstantErrorMsg, #footerLengthErrorMsg").html("");
			}else{
				$("#footerAvailableErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.footerAvailableOrNot" />');
// 				$("#dynamicFooterDiv").hide();
			}
		});
	// mohan raj
//nancy footer
		$("#controlTagCount").change(function(){
			 var iteration = 0;
			 var itr = 0;
			   var output = "";
			   iteration = $("#controlTagCount").val();
			   numberOfFormat = $("#numberOfFormat").val();
			   var itr = iteration*numberOfFormat;
			   footerType =  $("#footerType").val();
			   if(iteration > 0){
		   			for ( var i = 0; i < iteration; i++ ) {
		 			   var hiddenDivValue = "";
		   				
		   				for( var j = 0 ; j <numberOfFormat; j++ ) {
		   					
		   					hiddenDivValue =  hiddenDivValue +
		   					                         
								   					"<spring:bind path='configForm.hiddenControlDataRecordField'>"+
													 	"<input type='hidden' id='hiddenControlDataRecordField-"+i+"-"+j+"' name='hiddenControlDataRecordField' >"+   
													 "</spring:bind>"+
													 "<spring:bind path='configForm.hiddenControlCheckField'>"+
														"<input type='hidden' id='hiddenControlCheckField-"+i+"-"+j+"' name='hiddenControlCheckField' >"+	 
													"</spring:bind>"+
													"<spring:bind path='configForm.hiddenControlCheckConstant'>"+
														"<input type='hidden' id='hiddenControlCheckConstant-"+i+"-"+j+"' name='hiddenControlCheckConstant' >"+
													"</spring:bind>";			
													
		   				}
		   									
		   				

		   				output = output +
		   			  "<tr>"+
		   			   		"<td>"+	
		   			   			"<spring:bind path='configForm.controlType'>"+
		   				   			"<select name = 'controlType' onchange='controlTypeVal(this.id,"+i+")' id='controlType-"+i+"'>"+
		   			       			     "<option value=''>Not Selected</option>"+
		   			       			     "<option value='cnt'>Count</option>"+
		   			       			     "<option value='sum'>Sum </option>"+
		   			       			"</select>"+
		   						"</spring:bind>"+
	   							"<span id='controlType-"+i+"ErrorMsg' class='col-lg-12 must'></span>"+
		   					"</td>"+
		   					
		   					"<td>"+ 
		   			   			"<spring:bind path='configForm.controlDataFromPosition'>"+
		   			   		       "<input type='text' name='controlDataFromPosition' maxlength='5' onchange='fromPositionValidation(this.id,"+i+")'  id='controlDataFromPosition-"+i+"' />"+
		   						"</spring:bind>"+
		   						"<span id='controlDataFromPosition-"+i+"ErrorMsg' class='col-lg-12 must'></span>"+
		   					"</td>"+
		   					
		   					"<td>"+ 
		   			   			"<spring:bind path='configForm.controlDataToPosition'>"+
		   			   			   "<input type='text' name='controlDataToPosition' maxlength='5' onchange='toPositionValidation(this.id,"+i+")' id='controlDataToPosition-"+i+"'/>"+
		   						"</spring:bind>"+
		   						"<span id='controlDataToPosition-"+i+"ErrorMsg' class='col-lg-12 must'></span>"+
		   					"</td>"+
		   					
		   					"<td>"+ 
		   			   			"<spring:bind path='configForm.controlDataColumnPosition'>"+
		   			   			   "<input type='text' name='controlDataColumnPosition' maxlength='15' onchange='columnPositionVal(this.id,"+i+")'  id='controlDataColumnPosition-"+i+"'/>"+
		   						"</spring:bind>"+
		   						"<span id='controlDataColumnPosition-"+i+"ErrorMsg' class='col-lg-12 must'></span>"+
		   					"</td>"+
		   					"<td>"+
								"<input type='button' value='...' name='actionBtn' id='templatecheck-"+i+"' onclick='openPopUPWindow(this, "+i+")' class='btn btn-primary '>"+
								"<span id='templatecheck-"+i+"ErrorMsg' class='col-lg-12 must'></span>"+
							""+hiddenDivValue+""+	
							"</td>"+
		   					"</tr>";
		   					
		   					
		   				
		   			}
		   			$("#dynamicFooterDiv").show();
					$("#noOfLinesFooterInnerDiv").html(output);
			   		}else{
						$("#dynamicFooterDiv").hide();
					}
			   footerTypeValidation();
			   		
		});
		
		$("#footerType").change(function(){
			var val = $(this).val();
			
			if(val == 'F'){
				$("#footerTypeErrorMsg").html("");
			}else if(val ==  'D'){
				$("#footerTypeErrorMsg").html("");
			}
		});
		
		$("#footerBeginsConstant").change(function(){
			var val = $(this).val();
			if(val != null &&  val!= ""){
				$("#footerBeginsConstantErrorMsg").html("");
			}
		});
		
		
		// Footer Submit Button is Clicked
		$("#footerDetailsBtnId").click(function() {
			
			var footerResult = true;
			var footerAvailable = $.trim($("#footerAvailable").val());
			var iteration = $("#controlTagCount").val();
			var iteration1 = $("#numberOfFormat").val()
		 	var footerType = $("#footerType").val();
			var fileType = $("#fileType").val();
			
			 if(footerAvailable == 'Y'){
				var footerType = $.trim($("#footerType").val());
				var controlTag = $.trim($("#controlTagCount").val());
				var footerLength = $.trim($("#footerLength").val());
				if(footerType == ""){
					$("#footerTypeErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectFooterType" />');
					footerResult = false;
				}
				if(fileType != "X" && footerLength == ""){//condition fileType = "X" added by nancy on 11-05-16 for xml to remove mandatory check in  footer length field
					$("#footerLengthErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectFooterLength"/>');
					footerResult = false;
				}
				//control tag count not mandatory for Excel modified by Nancy on 17-May-2017
				if(fileType !='E'){
					 if (controlTag == "") {
						$("#controlTagCountErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.emptyControlTagCount" />');
						footerResult = false;
					}
				} 
			}else if(footerAvailable == ""){
				footerResult = false;
				$("#footerAvailableErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectFooterAvailable" />');
			}
			
			//Valiadtion
            if( footerType == 'F'){
           	 for(var i=0 ;i<iteration ;i++){
           		 if( ($("#controlDataFromPosition-"+i+"").val() == "") && ($("#controlDataToPosition-"+i+"").val() == "")){
           			 $("#controlDataFromPosition-"+i+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.emptyFromPosition"/>');
           			 $("#controlDataToPosition-"+i+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.emptyToPosition"/>');
           			footerResult = false;
                  }else if(($("#controlDataFromPosition-"+i+"").val() == "")&& ($("#controlDataToPosition-"+i+"").val() != "")){
           			 $("#controlDataFromPosition-"+i+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.emptyFromPosition"/>');
           			footerResult = false;
                  }else if(($("#controlDataFromPosition-"+i+"").val() != "")&& ($("#controlDataToPosition-"+i+"").val() == "")){
         			 $("#controlDataToPosition-"+i+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.emptyToPosition"/>');
         			footerResult = false;
                  }
           	 }
            } else if(footerType == 'D') {  
           	 for(var i=0 ;i<iteration ;i++){
           		 if( ($("#controlDataColumnPosition-"+i+"").val() == "")){
           			 $("#controlDataColumnPosition-"+i+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.emptyColumnPosition"/>');
           			footerResult = false;
                 }else {
               	   $("#controlDataColumnPosition-"+i+"ErrorMsg").html("");
                  }
           	 }
            }
            //added by Nancy for popup window
            //control type validation
            if(fileType !='E'){//Added by Nancy to skip validation for excel type on 17-May-2017
	            for(var i=0 ;i<iteration ;i++){
	            	var controlType = $("#controlType-"+i).val();
	            	 if( controlType == ""){
	   	 			   $("#controlType-"+i+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.emptyControlType"/>');
	   	 			 footerResult = false;
	   	 		   }else{
	   	 			$("#controlType-"+i+"ErrorMsg").html('');
	   	 			$("#controlType-"+i+"ErrorMsg").hide();
	   	 		   }
	            }
			 	 
		      //popup button validation
	            for(var i=0 ;i<iteration ;i++){
	  	    	  var controlType = $("#controlType-"+i).val();
	  			   for(var j=0; j<iteration1 ; j++){
	  				    var recordFields = $("#hiddenControlDataRecordField-"+i+"-"+j+"").val();
	  	 	 		    if( controlType == 'sum'){
	  						if(recordFields == "" || recordFields == null ){
	  	 						$("#templatecheck-"+i+"ErrorMsg").html('select the button');
	  	 			 			footerResult = false;
	  	 				}else{
	  		 			  $("#templatecheck-"+i+"ErrorMsg").html('');
	  		 			  $("#templatecheck-"+i+"ErrorMsg").hide();
	  		 		 }
	  			   }
	  			}
	  	      }
			
			 //column Position validation
				var tempColumn = new Array();
				for(var k=0;k<iteration;k++){
				if(($("#controlDataColumnPosition-"+k+"").val() != null) || (($("#controlDataColumnPosition-"+k+"").val())) != ""){
				
				for(var j=0;j<iteration;j++){
					
					tempColumn[j] = $("#controlDataColumnPosition-"+j+"").val();
				}
				
				for(var i=0; i<iteration ; i++){
					tempColumn[i] = $("#controlDataColumnPosition-"+i+"").val();
					if(parseInt(tempColumn[i])== 0){
						$("#controlDataColumnPosition-"+i+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.invalidNumber"/>');
						footerResult = false;
					}
				}
				for(var i=0; i<iteration ; i++){
					if(i!=0){
					for(var j=0;j<i;j++){
					if($("#controlDataColumnPosition-"+j+"").val() != ""){
						
						if (footerResult == true) {
								var Column = parseInt(tempColumn[i]);
								var column1 =parseInt(tempColumn[j]);
								if (Column == column1) {
									var alreadyExist = '<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.alreadyExist"/>';								
									footerResult = false;
									$("#controlDataColumnPosition-"+i+"ErrorMsg").html(Column	+ " "+alreadyExist);
								} else {
									$("#controlDataColumnPosition-"+i+"ErrorMsg").html("");
								}
					
				}}}}
         	}
		    }
			}
			
			//from and To Position validation
			var tempFrom = new Array();
			var tempTo = new Array();
			var from;
			var to;
			for(var k=0;k<iteration;k++){
				if(($("#controlDataFromPosition-"+k+"").val() != "") || (($("#controlDataToPosition-"+k+"").val())) != ""){
						
			for(var j=0;j<iteration;j++){
							
				tempFrom[j] = $("#controlDataFromPosition-"+j+"").val();
				tempTo[j] = $("#controlDataToPosition-"+j+"").val();
						}
			for(var j=0;j<iteration;j++){
				
				tempFrom[j] = $("#controlDataFromPosition-"+j+"").val();
				if(parseInt(tempFrom[j])== 0){
					$("#controlDataFromPosition-"+j+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.invalidNumber"/>');
					footerResult = false;
				}
				tempTo[j] = $("#controlDataToPosition-"+j+"").val();
				if(parseInt(tempTo[j])== 0){
					$("#controlDataToPosition-"+j+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.invalidNumber"/>');
					footerResult = false;
				}
						}
			
			if(tempFrom.length == tempTo.length){
				for(var i=0; i<iteration ; i++){
					for(var j=0;j<i;j++){
						from = parseInt(tempFrom[i]);
						to = parseInt(tempTo[i]);
						from1 = parseInt(tempFrom[j]); 
						to1 = parseInt(tempTo[j]);
							
						
						if(from > to){
							$("#controlDataToPosition-"+i+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.invalidToPosition"/>');
				   			footerResult = false;
						}
						if(from1 > to1){
							$("#controlDataToPosition-"+j+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.invalidToPosition"/>');
				   			footerResult = false;
						}
					}
				}
			}}} 
            }
			//added to fix mantis issue id 14111			
			if( parseInt( $.trim( $("#footerLength").val() ) ) == 0 ) {
				footerResult = false;
				$("#footerLengthErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.shouldBeMoreThan1" />');
				$("#footerLengthErrorMsg").show();
			}
			
			if(footerResult){
				var iteration = $("#controlTagCount").val();
				$("#headerWithDr").attr("disabled", false);
				$("#headerBeginsCheckApplicable-0").attr("disabled", false);
				$("#footerType").attr("disabled", false);
				$("#multiFormatDataSupport").attr("disabled", false);
				$("#dataFormat").attr("disabled" , false);
				$("#footerAvailable").attr("disabled",false);
				
				 for(var i=0;i<iteration;i++){
	  			   //$("#controlDataRecordField-"+i+"").attr("disabled" , false);
	  			   $("#controlDataFromPosition-"+i+"").attr("disabled" , false);
	  			   $("#controlDataToPosition-"+i+"").attr("disabled" , false);
	  			   $("#controlDataColumnPosition-"+i+"").attr("disabled" , false);
	  			   //$("#controlCheckConstant-"+i+"").attr("disabled" , false);
	  		   }
				 
				$("#inputFileConfigForm").attr('action', 'addInputFileConfig.rcn');
				$("#inputFileConfigForm").submit();			
			} 
		});
		
//Footer Validations Ends
	
//Data Record Validation Start  mohan raj

		//dataFormat onchange
		$("#dataFormat").change(function(){
			$("#DataRecordDivId").empty();
			$("#showaddbtn").hide();//multem
			$("#showminusbtn").hide();//multem
			$("#multiFormatDataSupport").val("");
			$("#numberOfFormat").val("");
			$("#DataRecordDivId").hide();
			$("#dataFormatErrorMsg").html("");

			var dataFormat = $("#dataFormat").val();
			if(dataFormat == 'V'){
				$("#varaiableLengthHiddenFieldDiv").show();
			} else {
				$("#varaiableLengthHiddenFieldDiv").hide();
				$("#blockSizeAvailable").val("");
				$("#blockSize").val("");				
			}
		});
		
		//multiFormatDataSupport onchange
		  $("#multiFormatDataSupport").change(function(){
			  
			  $("#DataRecordDivId").empty();//multem
			 var multiFormatDataSupport = $("#multiFormatDataSupport").val();
			 var dataFormat = $("#dataFormat").val();
			 $("#multiFormatDataSupportErrorMsg").html("");
			 var fileType = $("#fileType").val();
			 
			 if(dataFormat != ""){
				 $("#dataFormatErrorMsg").html("");
			 if(multiFormatDataSupport == 'N'){
				 $("#DataRecordDivId").empty();//multem
				 $("#showaddbtn").hide();//multem 
				 $("#showminusbtn").hide();//multem
				 //$("#numberOfFormat").val(1);
				 $("#numberOfFormatErrorMsg").html("");
							 
				 $("#numberOfFormat").attr("readonly" , true);
				
				//hemnnn123
				 
				 if(fileType == "E"){
					 $("#numberOfFormat").val("");
				 }else{
					 $("#numberOfFormat").val(1);
				 }
				 var noOfFormat = $("#numberOfFormat").val();
				 fn_generatingTable(dataFormat, noOfFormat);  // function to generate dynamic table
				 
			 } else if(multiFormatDataSupport == 'Y') {
				
				 var numberOfFormat = $.trim($("#numberOfFormat").val());
				 //modified by Nancy for multisupport in excel on 25-07-17//hemnnn
				 if(fileType == "E"){
					 $("#showaddbtn").hide();
				 }else{
					 $("#showaddbtn").show();//multem
				 }
				//hemnnn
				 //$("#numberOfFormat").attr("readonly" , false);
				 $("#numberOfFormat").val(0);
				 $("#numberOfFormatErrorMsg").html("");
				 $("#multiFormatDataSupportErrorMsg").html("");
				 callPlusRowFun();//to Add rows according to no. of format 
				 var numberOfFormat = $.trim($("#numberOfFormat").val());
				 //modified by Nancy for multisupport in excel on 25-07-17//hemnnn
				 if(fileType != "E"){
					 if(numberOfFormat == ""){
						 	$("#DataRecordDivId").hide();
						 } 
				 }
				//hemnnn
			 } else if(multiFormatDataSupport == '') {
				 
				 $("#showaddbtn").hide();//multem
				 $("#numberOfFormat").attr("readonly" , true);
				 $("#numberOfFormat").val("");
				 $("#numberOfFormatErrorMsg").html("");
// 				 $("#multiFormatDataSupportErrorMsg").html("Select the Multiple Format Data Record Support");
				 $("#DataRecordDivId").hide();
			 }
			 } else {
				 $("#dataFormatErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectDataFormat"/>');
			 }
		  });
//Data Record Validation End.

		//on dr next button Validation
		
		$("#dataRecordNextButton").click(function(){
			var drResult = true;
			var dataFormat = $("#dataFormat").val();
			var multiFormatDataSupport = $.trim($("#multiFormatDataSupport").val());
			var numberOfFormat = $("#numberOfFormat").val();
			var fileType = $("#fileType").val();
			
			if(dataFormat == ""){
				$("#dataFormatErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectDataFormat"/>');
				$("#dataFormatErrorMsg").show();
				drResult = false;
			} else {
				$("#dataFormatErrorMsg").html("");
				$("#dataFormtaErrorMsg").hide();
					
				if ( fileType != 'E' ) {  
					if(multiFormatDataSupport == ""){
						$("#multiFormatDataSupportErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.multipleFormatDrSupport"/>');
						$("multiFormatDataSupportErrorMsg").show();
						drResult = false;
					} else {
						$("#multiFormatDataSupportErrorMsg").html("");
						$("multiFormatDataSupportErrorMsg").hide();
						if(multiFormatDataSupport == 'Y'){
							if(numberOfFormat == ""){
								$("#numberOfFormatErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterNoOfFormat"/>');
								$("#numberOfFormatErrorMsg").show();
								drResult = false;
							} else {
								$("#numberOfFormatErrorMsg").html("");
								$("#numberOfFormatErrorMsg").hide();
								if(numberOfFormat == 0){
									$("#numberOfFormatErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.shouldBeMoreThan1"/>');
									$("#numberOfFormatErrorMsg").show();
									drResult = false;
								} else {
									$("#numberOfFormatErrorMsg").html("");
									$("#numberOfFormatErrorMsg").hide();
								}
							}
							
						} else {
							$("#numberOfFormatErrorMsg").html("");
							$("#numberOfFormatErrorMsg").hide();
						}
					}
					if(dataFormat == 'V'){
						
						if($("#blockSizeAvailable").val() == ""){
							$("#blockSizeAvailableErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectBlockSizeAvailable"/>');
							$("#blockSizeAvailableErrorMsg").show();
							drResult = false;
						} else {
							$("#blockSizeAvailableErrorMsg").html("");
							$("#blockSizeAvailableErrorMsg").hide();
							if( $("#blockSizeAvailable").val() == 'Y'){
								if($("#blockSize").val() == ""){
									$("#blockSizeErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterBlockSize"/>');
									$("#blockSizeErrorMsg").show();
									drResult = false;
								} else {
									$("#blockSizeErrorMsg").html("");
									$("#blockSizeErrorMsg").hide();
								}
							} else {
								$("#blockSizeErrorMsg").html("");
								$("#blockSizeErrorMsg").hide();
							}
						}
					}
				}//Added by Nancy for multisupport in excel on 25-07-17//hemnnn
				else{
					if(multiFormatDataSupport == ""){
						$("#multiFormatDataSupportErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.multipleFormatDrSupport"/>');
						$("multiFormatDataSupportErrorMsg").show();
						drResult = false;
					}else{
						$("#multiFormatDataSupportErrorMsg").html('');
						$("multiFormatDataSupportErrorMsg").hide();
					}
				}
				//hemnnn
			}
	
			if( drResult ){
				if(dataFormat == 'F'){
					if ( fileType == 'E' ){
						drResult = drTabExcelFileValidation();
					} else {
						drResult = drTabValidation(numberOfFormat, dataFormat);
					}
				} else if(dataFormat == 'V'){
					drResult = drTabValidation(numberOfFormat, dataFormat);
				} else if(dataFormat == 'K') {
					drResult = drTabValidation(numberOfFormat, dataFormat);	
				}
			}
// 			drResult = true //need to remove
			if( drResult ){
				var nextId = $(this).parents('.tab-pane').next().attr("id");
				$(".inactive-tab-wizard").find('.tab-pane').removeClass('in active');
				$(".inactive-tab-wizard").find('.'+nextId).tab('show');
			//	$(".inactive-tab-wizard").find('.tab-pane').css({"position":"absolute","top":"-1000px"});
				$(".inactive-tab-wizard").find('#'+nextId).removeAttr("style").addClass(' in active');
			}
			
		});

		$('.previous-v-tab').click(function(){	
			var prevId = $(this).parents('.tab-pane').prev().attr("id");
			$(".inactive-tab-wizard").find('.nav-tabs li').removeClass();
			$(".inactive-tab-wizard").find('.'+prevId).tab('show');
			//alert(prevId);
			$(".inactive-tab-wizard").find('.nav-tabs').removeClass('active');
			$(".inactive-tab-wizard").find('.tab-pane').removeClass(' in active');
			//$(".inactive-tab-wizard").find('.'+prevId).tab('show');
		//	$(".inactive-tab-wizard").find('.tab-pane').css({"position":"absolute","top":"-1000px"});
			$(".inactive-tab-wizard").find('#'+prevId).addClass(" in active");
			
		});	
		
		//cancel button onclick
		$("#cancelButton").click(function(){
			$("#inputFileConfigForm").attr('action', 'redirectInputFileConfig.rcn');
			$("#inputFileConfigForm").submit();	
		});
		
	// To Prevent copy Paste
		$('body').bind('copy paste',function(e){
			e.preventDefault();
			return false;
		});
	});
	
	//Added for File Name Convention by Srikanth
		function OpenWindow() {
			var contextRoot = "${pageContext.request.contextPath}";
			popupWindow = window.open(contextRoot +"/Namingconvention.jsp","Namingconvention","height=500,width=500,scrollbars=yes");
		}
	//End
	//added by nancy footer popupwindow
	
	function openPopUPWindow(id,i) {
		
		if($('#controlType-'+i).val() == ""){
			$('#controlType-'+i+'ErrorMsg').html('Select the control type');
		}else{
			$('#controlType-'+i+'ErrorMsg').html('');
			$('#controlType-'+i+'ErrorMsg').hide();
			var controlType = $("#controlType-"+i).val();
			$("#hiddenActionDiv").empty();
			var popupContent = "";
			var head ="";
			var tableBody="";
			var iteration = $("#numberOfFormat").val();
			var iteration1 = $("#controlTagCount").val();
			if(iteration > 0){
				
			head= 	"<thead class='table-head'>"+
						"<tr>"+
							"<th>"+
								"<spring:message code='masters.inputFileConfig.controlDataRecordsField'/>"+
							"</th>"+
							"<th>"+
								"<spring:message code='masters.inputFileConfig.controlCheckFields'/>"+
							"</th>"+
					 	 	"<th>"+
					 	 		"<spring:message code='masters.inputFileConfig.controlCheckConstant'/>"+
					 	 	"</th>"+
						"</tr>"+
					"</thead>";
						
			footer =		 "<div class='text-center col-lg-6 col-lg-offset-1'>"+
								"<p class='text-center'>"+
									"<input type='button' value='save' align='center' name='saveButton' id='saveButton-"+i+"' class='btn btn-primary' onclick='savePopUpWindow(this.id,"+i+")'/>"+
								"</p>"+
							"</div>";
			for ( var j = 0; j < iteration; j++ ) {
				if(controlType == 'cnt'){
					popupContent =  popupContent +
					
				 	"<tr>"+ 
				 
				  	"<td>"+ 
			   			"<spring:bind path='configForm.controlDataRecordField'>"+
					   		 "<select name='controlDataRecordField' onchange='recordFieldValidation(this.id,"+i+","+j+")' disabled = 'disabled' id='controlDataRecordField-"+i+"-"+j+"'style='width:281px'>"+
					             "<option value=''>Not Selected</option>"+
					         "</select>"+
						"</spring:bind>"+
						"<span id='controlDataRecordField-"+i+"-"+j+"ErrorMsg' class='col-lg-12 must'></span>"+
						"<spring:bind path='configForm.hiddenTemplateFields'>"+
							"<input type='hidden' id='hiddenTemplateFields-"+i+"-"+j+"' name='hiddenTemplateFields' >"+   
				 		"</spring:bind>"+
					"</td>"+

					"<td>"+ 
						"<spring:bind path='configForm.controlCheckField'>"+
			   				"<select name = 'controlCheckField' onchange='checkFieldFunction(this.id,"+i+","+j+")'  id='controlCheckField-"+i+"-"+j+"' style='width:281px'>"+
		    			    	"<option value=''>Not Selected</option>"+
		    				"</select>"+
						"</spring:bind>"+
						"<span id='controlCheckField-"+i+"-"+j+"ErrorMsg' class='col-lg-12 must'></span>"+
					"</td>"+
				
					"<td>"+ 
						"<spring:bind path='configForm.controlCheckConstant'>"+
				       		"<input type='text' name='controlCheckConstant' onkeypress='checkConstantFunction(this.id,"+i+","+j+")' maxlength='5' disabled='true'  id='controlCheckConstant-"+i+"-"+j+"' />"+
						"</spring:bind>"+
						"<span id='controlCheckConstant-"+i+"-"+j+"ErrorMsg' class='col-lg-12 must'></span>"+
					"</td>"+ 
				     
				"</tr>";
				} else{
					popupContent =  popupContent +
					
				 	"<tr>"+ 
				 
				  "<td>"+ 
			   			"<spring:bind path='configForm.controlDataRecordField'>"+
					   		 "<select name='controlDataRecordField' onchange='recordFieldValidation(this.id,"+i+","+j+")' id='controlDataRecordField-"+i+"-"+j+"'style='width:281px'>"+
					             "<option value=''>Not Selected</option>"+
					         "</select>"+
						"</spring:bind>"+
						"<span id='controlDataRecordField-"+i+"-"+j+"ErrorMsg' class='col-lg-12 must'></span>"+
						"<spring:bind path='configForm.hiddenTemplateFields'>"+
							"<input type='hidden' id='hiddenTemplateFields-"+i+"-"+j+"' name='hiddenTemplateFields' >"+   
				 		"</spring:bind>"+
					"</td>"+

					"<td>"+ 
						"<spring:bind path='configForm.controlCheckField'>"+
			   				"<select name = 'controlCheckField' onchange='checkFieldFunction(this.id,"+i+","+j+")'  id='controlCheckField-"+i+"-"+j+"' style='width:281px'>"+
		    			    	"<option value=''>Not Selected</option>"+
		    				"</select>"+
						"</spring:bind>"+
						"<span id='controlCheckField-"+i+"-"+j+"ErrorMsg' class='col-lg-12 must'></span>"+
					"</td>"+
				
					"<td>"+ 
						"<spring:bind path='configForm.controlCheckConstant'>"+
				       		"<input type='text' name='controlCheckConstant' onkeypress='checkConstantFunction(this.id,"+i+","+j+")' maxlength='5' disabled='true'  id='controlCheckConstant-"+i+"-"+j+"' />"+
						"</spring:bind>"+
						"<span id='controlCheckConstant-"+i+"-"+j+"ErrorMsg' class='col-lg-12 must'></span>"+
					"</td>"+ 
				     
				"</tr>";
				}				
			}
			}
			tableBody = "<table border='1' align='center' id='tableTempDef' class='table table-hover table-striped table-bordered'>"+
			head+
			popupContent+
			"</table>"+
			footer;
			
			$("#DemomyModal").show();
			$("#hiddenActionDiv").append(tableBody);
			$("#hiddenActionDiv").show();
			
			
			
			//footerTypeValidation();
			
		
			 if($("#footerAvailable").val()  == "Y" && $.trim($("#controlTagCount").val()) != "" ){
				 
				 var templateId = ""; 
				 var numberOfFormat = $("#numberOfFormat").val();
				 for(var z = 1; z <= numberOfFormat ;z++){				 
//					 templateId[j] = $("#templateId-"+i).val();
					 if(z < numberOfFormat){
						 templateId = templateId+$("#templateId-"+z).val()+"|";	 
					 } else if(z == numberOfFormat){
						 templateId = templateId+$("#templateId-"+z).val();
					 } 
					 	 
				 }
				 				 
				 $.ajax({
					url 		: "getRecordFieldAjax.rcn?templateId="+templateId,
				  	type		: "POST" ,
				  	dataType	: 'json', 
					contentType	: 'application/json',
					mimeType	: 'application/json',
	 				async		: false
						 
	    		   }).done(function(response){
		    			  //alert(response); // 2 OBJECT 
		    			  $.each(response , function(index , value){
//	 	    				 alert(index +" :"+value); // 0 -object
//								alert(index);
		    						 $("#controlDataRecordField-"+i+"-"+index+"").find('option').remove().end().append('<option value="">Not Selected</option>').val('');
		    						  $.each(value , function(key , val){
		    							$('<option>').val(key).text(val).appendTo("#controlDataRecordField-"+i+"-"+index+""); 
		    						  });
//	 	    							
		    						  $("#controlCheckField-"+i+"-"+index+"").find('option').remove().end().append('<option value="">Not Selected</option>').val('');
		    						  $.each(value , function(key , val){
	    								$('<option>').val(key).text(val).appendTo("#controlCheckField-"+i+"-"+index+""); 
	   								  });
//	 	    						
		    				 });
		    			  });
			 }
			 for(var z=0,h=1; z<iteration; z++,h++){
				 
				$("#controlDataRecordField-"+i+"-"+z+"").val($("#hiddenControlDataRecordField-"+i+"-"+z+"").val());
				$("#controlCheckField-"+i+"-"+z+"").val($("#hiddenControlCheckField-"+i+"-"+z+"").val());
				$("#controlCheckConstant-"+i+"-"+z+"").val($("#hiddenControlCheckConstant-"+i+"-"+z+"").val());
				$("#hiddenTemplateFields-"+i+"-"+z+"").val($("#templateId-"+h+"").val());
				
				//added for change of control type
				if(controlType == 'cnt'){
					$("#controlDataRecordField-"+i+"-"+z+"").val("");
				}
				//for check constant 
				var checkField = $("#controlCheckField-"+i+"-"+z+"").val();
				if(checkField != ""){
					$("#controlCheckConstant-"+i+"-"+z+"").attr("disabled", false);
				}else{
					$("#controlCheckConstant-"+i+"-"+z+"").attr("disabled", true);
				}
					
			}  
		}
	}	
	
		
	
	function addNewRow(id,row){
		var dataFormat = $("#dataFormat").val();
		var arr = [];
		var lastrowid = "";
		var i= "";
		
		if(dataFormat == 'F'){
			var totalrow = parseInt($("#fixedDataRecordTableId-"+row+" tbody tr").length);
		} else if(dataFormat == 'V'){
			var totalrow = parseInt($("#variableDataRecordTableId-"+row+" tbody tr").length);	
		} else if(dataFormat == 'K'){
			var totalrow = parseInt($("#keyBasedDataRecordTableId-"+row+" tbody tr").length);			
		}
		
		
		if(totalrow == '0'){
			lastrowid = "DE"+row+"_1";
			i = lastrowid;
		} else {
			
			if(dataFormat == 'F'){
				 lastrowid = $("#fixedDataRecordTableId-"+row+" tbody>tr:last").attr("id");
			} else if(dataFormat == 'V'){
				 lastrowid = $("#variableDataRecordTableId-"+row+" tbody>tr:last").attr("id");	
			} else if(dataFormat == 'K'){
				 lastrowid = $("#keyBasedDataRecordTableId-"+row+" tbody>tr:last").attr("id");			
			}
			
			arr = lastrowid.split("_");
			var x = parseInt(arr[1])+1;
			var i = arr[0]+"_"+x ;
		} 
		
		//add new row for keyBased
		
		if(dataFormat == 'K'){
		var tableBody ="";
		
			tableBody = "" +
						"<tr id="+i+">"+
							"<td>"+
								"<spring:bind path='configForm.drIdentifier'>"+
									"<input id='drIdentifier-"+i+"' name='drIdentifier' type='text' maxlength='50' onchange ='hideErrorMsg(this.id)' class='formtextbox'/>"+
								"</spring:bind>"+
								"<div id='drIdentifier-"+i+"ErrorMsg' class='must'></div>"+
							"</td>"+
							"<td>"+
								"<spring:bind path='configForm.drOffset'>"+
									"<input id='drOffset-"+i+"' name='drOffset' type='text' maxlength='50' onkeypress ='return validateOffsetCharecter(this.id,event)' class='formtextbox'/>"+
								"</spring:bind>"+
								"<div id='drOffset-"+i+"ErrorMsg' class='must'></div>"+
							"</td>"+
							"<td>"+
								"<spring:bind path='configForm.parentChildIndicator'>"+
									"<select id='parentChildIndicator-"+i+"' name='parentChildIndicator' onchange = 'parentChildValidation(this.id)'>"+
										"<option value = ''>Not Selected</option>"+
										"<option value = 'P'>Parent</option>"+
										"<option value = 'C'>Child</option>"+
									"</select>"+
								"</spring:bind>"+
								"<div id='parentChildIndicator-"+i+"ErrorMsg' class='must'></div>"+
							"</td>"+
							"<td>"+
								"<spring:bind path='configForm.parent'>"+
									"<input id='parent-"+i+"' name='parent' type='text' class='formtextbox' onchange ='hideErrorMsg(this.id)' maxlength='50' readonly = 'true' />"+
								"</spring:bind>"+
								"<div id='parent-"+i+"ErrorMsg' class='must'></div>"+
							"</td>"+
							"<td>"+
								"<spring:bind path='configForm.columns'>"+
									"<input id='columns-"+i+"' name='columns' type='text' maxlength='150' onkeypress = 'return columnsValidation(this.id , event)' class='formtextbox'/>"+
								"</spring:bind>"+
								"<div id='columns-"+i+"ErrorMsg' class='must'></div>"+
							"</td>"+
							"<td>"+
								"<spring:bind path='configForm.stringIdentifier'>"+
									"<select name='stringIdentifier' id='stringIdentifier-"+i+"' onchange='stringIdentifierValidaiton(this.id)' >"+
										"<option value=''>Not Selected</option>"+
										"<option value='contains'>Contains</option>"+
										"<option value='skip'>Skip</option>"+
										"<option value='skipr'>SkipAndReturn</option>"+
										"<option value='next'>Next</option>"+
										"<option value='next_2'>Next Two</option>"+
										"<option value='fixed'>Fixed</option>"+
										"<option value='mergeAndFixed'>MergeAndFixed</option>"+
										"<option value='next_5'>Next-5</option>"+
										"<option value='end'>End</option>"+
										"<option value='merge'>Merge</option>"+
// 										"<option value='endWith'>End With</option>"+
// 										"<option value='allNumeric'>All Numeric</option>"+
// 										"<option value='starts'>Starts</option>"+
										"<option value='none'>None</option> "+
									"</select>"+
								"</spring:bind>"+
								"<div id='stringIdentifier-"+i+"ErrorMsg' class='must'></div>"+
							"</td>"+
// 							"<td>"+
								"<spring:bind path = 'configForm.hiddenTemplateId'>"+
									"<input id='hiddenTemplateId-"+i+"' name='hiddenTemplateId' type='hidden' />"+
								"</spring:bind>"+
// 							"</td>"+
							"<td>"+
// 				        	 "<input type='button' value='Delete' name='btnDelete' class='btn gradient'  id='deleteBtn-"+i+"' onclick='removeAction(this);'>"+ 
				        	 "<button type='button' class='btn btn-default' aria-label='Left Align' name='btnDelete' onclick='removeAction(this);' id='deleteBtn-"+i+"'>"+
							 "<span class='glyphicon glyphicon-minus' aria-hidden='true'></span> </button>"+	 
				   		 "</td>"+
					"</tr>";
					
					 $("#keyBasedDataRecordTableId-"+row+" tbody").append(tableBody);
		}
		//Add new row for Fixed and varaible Length
		
		if(dataFormat == 'F' || dataFormat == 'V'){
			var tableBody ="";
			
				tableBody = "" +
							"<tr id="+i+">"+
								"<td>"+
									"<spring:bind path='configForm.drIdentifier'>"+
										"<input id='drIdentifier-"+i+"' name='drIdentifier' maxlength='50' onchange ='hideErrorMsg(this.id)'  type='text' class='formtextbox'/>"+
									"</spring:bind>"+
									"<div id='drIdentifier-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+
									"<spring:bind path='configForm.drOffset'>"+
										"<input id='drOffset-"+i+"' name='drOffset' type='text' maxlength='50' onkeypress ='return NumericValidation(this.id,event)' class='formtextbox'/>"+
									"</spring:bind>"+
									"<div id='drOffset-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
// 								"<td>"+
									"<spring:bind path = 'configForm.hiddenTemplateId'>"+
										"<input id='hiddenTemplateId-"+i+"' name='hiddenTemplateId' type='hidden' />"+
									"</spring:bind>"+
// 								"</td>"+
								"<td>"+
					        	 "<button type='button' class='btn btn-default' aria-label='Left Align' name='btnDelete' onclick='removeAction(this);' id='deleteBtn-"+i+"'>"+
								 "<span class='glyphicon glyphicon-minus' aria-hidden='true'></span> </button>"+
					   		 "</td>"+
						  "</tr>";
						
						  if(dataFormat == 'V'){
								 $("#variableDataRecordTableId-"+row+" tbody").append(tableBody);							  
						  } else if(dataFormat == 'F') {
							  $("#fixedDataRecordTableId-"+row+" tbody").append(tableBody);
						  }
			}

	}
	//modified by Nancy for multisupport in excel on 25-07-17//hemnnn
	function addNewExcelRow(){
		var tableBody = "";
		var lastrowid = $("#fixedExcelDrTableId tbody>tr:last").attr("id");
		var i = parseInt(lastrowid)+1;
		var multiFormatDataSupport= $("#multiFormatDataSupport").val();
		if(multiFormatDataSupport == "N"){	
			tableBody = tableBody+
								"<tr id="+i+">"+
								"<td>"+
									"<spring:bind path='configForm.sheetName'>"+
										"<input id='sheetName-"+i+"' name='sheetName' maxlength='50'  type='text' onkeypress ='return alphaNumericUnderScoreValidation(this.id,event)' onchange='fn_toUpperCase(this.id)'  class='formtextbox'/>"+ //modified by Dharun to allow underscore for sheetname
									"</spring:bind>"+
									"<div id='sheetName-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+
									"<spring:bind path='configForm.TemplateId'>"+
										"<select name = 'templateId' id='templateId-"+i+"' onchange ='fnTemplateErrorMsg(this.id)'>"+
											"<option value=''>Not Selected</option>"+
										"</select>"+
									"</spring:bind>"+
									"<div id='templateId-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+
									"<spring:bind path='configForm.drStartLineNo'>"+
										"<input id='drStartLineNo-"+i+"' name='drStartLineNo' maxlength='3' onkeypress ='return NumericValidation(this.id,event)'  type='text'  class='formtextbox'/>"+
									"</spring:bind>"+
									"<div id='drStartLineNo-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+								
// 									"<input type='checkbox' checked  id='toggle-two"+i+"' value='Y'>"+
//   									"<input type='hidden' checked name='templateEnableOrDisable'  id='toggle-two-data"+i+"' value='Y'>"+
  								// added by Mohan Raj.V on 02-11-17 for Toggle button change
									"<spring:bind path='configForm.templateEnableOrDisable'>"+
										"<button type='button' id='toggleBtn-"+i+"' class='col-lg-0 col-lg-offset-6 btn btn-lg btn-toggle active' data-toggle='button' aria-pressed='true' onclick='fn_ToggleOnchange("+i+",this)' autocomplete='off'><div class='handle'></div></button>"+
										"<input type='hidden' name='templateEnableOrDisable'  id='toggle-two-data"+i+"' value='Y'>"+
									"</spring:bind>"+
								"</td>"+
								"<td>"+
									"<button type='button' class='btn btn-default' aria-label='Left Align' name='btnDelete' onclick='removeActionForExcel(this.id);' id='deleteBtn-"+i+"'>"+
									"<span class='glyphicon glyphicon-minus' aria-hidden='true'></span> </button>"+
							 		"</td>"+
							"</tr>";
		}else if(multiFormatDataSupport == "Y"){
			tableBody = tableBody+
								"<tr id="+i+">"+
								"<td>"+
									"<spring:bind path='configForm.sheetName'>"+
										"<input id='sheetName-"+i+"' name='sheetName' maxlength='50' onkeypress ='return alphaNumericUnderScoreValidation(this.id,event)' onchange='fn_toUpperCase(this.id)' type='text'  class='formtextbox' style='width:200px'/>"+   
									"</spring:bind>"+
									"<div id='sheetName-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+
									"<spring:bind path='configForm.startText'>"+
										"<input id='startText-"+i+"' name='startText' maxlength='50'  onchange='fn_toUpperCase(this.id);fnStartTextErrorMsg(this.id)' onkeypress = 'return fnStartTxtVal(this.id,event)' type='text'  placeholder='Ex. A|CellValue' class='formtextbox' style='width:200px'/>"+   
									"</spring:bind>"+
									"<div id='startText-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+
									"<spring:bind path='configForm.endText'>"+
										"<input id='endText-"+i+"' name='endText' maxlength='50'  onchange='fn_toUpperCase(this.id);fnEndTextErrorMsg(this.id)' onkeypress = 'return fnStartTxtVal(this.id,event)' type='text'  placeholder='Ex. A|CellValue' class='formtextbox' style='width:200px'/>"+   
									"</spring:bind>"+
									"<div id='endText-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+
									"<spring:bind path='configForm.TemplateId'>"+
										"<select name = 'templateId' id='templateId-"+i+"' onchange ='fnTemplateErrorMsg(this.id)' style='width:200px'>"+
											"<option value=''>Not Selected</option>"+
										"</select>"+
									"</spring:bind>"+
									"<div id='templateId-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+
									"<spring:bind path='configForm.orderOfExe'>"+
										"<select name = 'orderOfExe' id='orderOfExe-"+i+"' onchange ='fnOrderOfExeErrorMsg(this.id)' style='width:200px' >"+
											"<option value=''>Not Selected</option>"+
											"<option value='1'>1</option>"+
											"<option value='2'>2</option>"+
											"<option value='3'>3</option>"+
											"<option value='4'>4</option>"+
											"<option value='5'>5</option>"+
											"<option value='6'>6</option>"+
											"<option value='7'>7</option>"+
											"<option value='8'>8</option>"+
											"<option value='9'>9</option>"+
										"</select>"+
									"</spring:bind>"+
									"<div id='orderOfExe-"+i+"ErrorMsg' class='must'></div>"+
								"</td>"+
								"<td>"+
// 						    		"<input type='checkbox' checked id='toggle-two"+i+"'  value='Y'>"+
// 						    		"<input type='hidden' checked name='templateEnableOrDisable'  id='toggle-two-data"+i+"'  value='Y'>"+
						    		// added by Mohan Raj.V on 02-11-17 for Toggle button change
									"<spring:bind path='configForm.templateEnableOrDisable'>"+
										"<button type='button' id='toggleBtn-"+i+"' class='col-lg-0 col-lg-offset-6 btn btn-lg btn-toggle active' data-toggle='button' aria-pressed='true' onclick='fn_ToggleOnchange("+i+",this)' autocomplete='off'><div class='handle'></div></button>"+
										"<input type='hidden' name='templateEnableOrDisable'  id='toggle-two-data"+i+"' value='Y'>"+
										"</spring:bind>"+
						        "</td>"+
								"<td>"+
									"<button type='button' class='btn btn-default' aria-label='Left Align' name='btnDelete' onclick='removeActionForExcel(this.id);' id='deleteBtn-"+i+"'>"+
									"<span class='glyphicon glyphicon-minus' aria-hidden='true'></span> </button>"+
						 		"</td>"+
						"</tr>";
		}
		
		$("#fixedExcelDrTableId tbody").append(tableBody);
		
		$('#toggle-two'+i).bootstrapToggle({
            on: 'Active',
            off: 'Inactive',
            width : '80px',
            height:'31px'
            //
          });
		
		$("#templateId-"+i).append($("#hiddenTemplateDiv").html());
	}
	

	
	
	
	function NumericValidationExcludedZero(id, e){
		//keycode =8 backspace
		//keycode =32 space bar
		//keycode =13 enter
		//keycode =9 tab
		//keycode =37 left arrow also %
		//keycode = 39 right arrow
		//keycode = 46 delete also (dot)
		
		var ret ;
		var keyCode =  e.which  ? e.which : e.keyCode;
		var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017
		if(btnCode == 'KeyA' || btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End') {
			ret = true;
		} else {
			//Key code 39(for Single Qoute) is removed by Anil Kumar D for Mantis Id : 14088
			//to remove 0 keycode started from 49 instead of 48
			ret = ((keyCode >= 49 && keyCode <= 57) || (keyCode >= 65 && keyCode <= 90) || /* (keyCode >= 97 && keyCode <= 122) || */(keyCode == 32)||(keyCode == 8)||(keyCode == 13)||(keyCode == 9)||(keyCode == 46));	//to allow  numerics
		}
		 if(!ret){
		    	$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidInput"/>');
		    	$("#"+id+"ErrorMsg").show();	    	
		    	
		    }else{
		    	$("#"+id+"ErrorMsg").html('');
		    	$("#"+id+"ErrorMsg").hide();
		    }
		return ret;
	}
	
	function alphaNumericValidation(id,e){
		//keycode =8 backspace
		//keycode =32 space bar
		//keycode =13 enter
		//keycode =9 tab
		//keycode =37 left arrow also %
		//keycode = 39 right arrow
		//keycode = 46 delete also (dot)
		var ret ;
		var keyCode =  e.which  ? e.which : e.keyCode;
		var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017
		if(btnCode == 'KeyA' || btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End') {
			ret = true;
		} else {
			//Key code 39(for Single Qoute) is removed by Anil Kumar D for Mantis Id : 14088
			ret = ((keyCode >= 48 && keyCode <= 57) || (keyCode >= 65 && keyCode <= 90) || (keyCode >= 97 && keyCode <= 122) ||(keyCode == 32)||(keyCode == 8)||(keyCode == 13)||(keyCode == 9)||(keyCode == 46));	//to allow alpha numerics
		}
		 if(!ret){
		    	$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidInput"/>');
		    	$("#"+id+"ErrorMsg").show();	    	
		    }else{
		    	$("#"+id+"ErrorMsg").html('');
		    	$("#"+id+"ErrorMsg").hide();
		    }
		return ret;
	}
	
	function hideErrorMsg(id){
		$("#"+id+"ErrorMsg").html("");
		$("#"+id+"ErrorMsg").hide();
	}
		
	function NumericValidation(id,e){
		//keycode =8 backspace
		//keycode =13 enter
		//keycode =9 tab
		//keycode =37 left arrow
		//keycode = 39 right arrow
		//keycode = 46 delete
		var ret ;
		var keyCode =  e.which  ? e.which : e.keyCode;
		var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017
		if(btnCode == 'KeyA' ||btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End') {
			ret = true;
		} else {
			// Key code 39(for Single Qoute) is removed by Anil Kumar D for Mantis Id : 14088
			ret = ((keyCode >= 48 && keyCode <= 57) || (keyCode == 8)||(keyCode == 13)||(keyCode == 9)||(keyCode == 46));	//to allow only numbers
		}
	    if(!ret){
	    	$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidNumber"/>');
	    	$("#"+id+"ErrorMsg").show();	    	
	    }else{
	    	$("#"+id+"ErrorMsg").html('');
	    	$("#"+id+"ErrorMsg").hide();
	    }
		return ret;
	}
	function alphaValidation(id,e){
		//keycode =8 backspace
		//keycode =13 enter
		//keycode =9 tab
		//keycode =37 left arrow
		//keycode = 39 right arrow
		//keycode = 46 delete
		var ret ;
		var keyCode =  e.which  ? e.which : e.keyCode;
		var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017
		if(btnCode == 'KeyA' ||btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End') {
			ret = true;
		} else {
			// Key code 39(for Single Qoute) is removed by Anil Kumar D for Mantis Id : 14088
			ret = ((keyCode >= 65 && keyCode <= 90) || (keyCode >= 97 && keyCode <= 122) ||(keyCode == 32)||(keyCode == 8)||(keyCode == 13)||(keyCode == 9)||(keyCode == 46));	//to allow alpha
		}
	    if(!ret){
	    	$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidNumber"/>');
	    	$("#"+id+"ErrorMsg").show();	    	
	    }else{
	    	$("#"+id+"ErrorMsg").html('');
	    	$("#"+id+"ErrorMsg").hide();
	    }
		return ret;
	}
	function ampersandValidation(id){
		    var status = true;
	    	var myString = $("#"+id).val();
			if(parseInt(myString.length) > 0){
				
				//This validation for first two character should not be &
				var firstChar = myString[0];
				var secondFirstChar = myString[1];
				
				if(firstChar == '&'){
					if(secondFirstChar == '&'){
							$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.firstAmpersandValidation"/>');
					    	$("#"+id+"ErrorMsg").show();
					    	return false;
					}
				}	
			
				//This validation for last two character should not be &
				var lastChar = myString[myString.length -1];
				var secondLastChar = myString[myString.length -2];
				
				if(secondLastChar == '&'){
					if(lastChar == '&'){
							$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.lastAmpersandValidation"/>');
					    	$("#"+id+"ErrorMsg").show();
					    	return false;
					}
				}
			
				// Dont repeat && more than one time
				var values = myString.split("&&");
				if(values.length > 2){
					$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.repetiveAmpersandValidation"/>');
			    	$("#"+id+"ErrorMsg").show();
			    	return false;
				}

				var offsetId = id.split("-DE")[0];
				var l = 0;
				var init;
				if(offsetId == "drOffset"){
					
						l = occurrences(myString,"&");
						if(l > 0 && l != 2){
							$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidAmpersandValidation"/>');
					    	$("#"+id+"ErrorMsg").show();
					    	return false;
						}
				}
			}
	    
		return status;
	}
	function orConditionValidation(id){
	    var status = true;
    	var myString = $("#"+id).val();
		if(parseInt(myString.length) > 0){
			
			//This validation for first two character should not be &
			var firstChar = myString[0];
			var secondFirstChar = myString[1];
			
			if(firstChar == '|'){
				if(secondFirstChar == '|'){
						$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.firstORValidation"/>');
				    	$("#"+id+"ErrorMsg").show();
				    	return false;
				}
			}	
		
			//This validation for last two character should not be &
			var lastChar = myString[myString.length -1];
			var secondLastChar = myString[myString.length -2];
			
			if(secondLastChar == '|'){
				if(lastChar == '|'){
						$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.lastORValidation"/>');
				    	$("#"+id+"ErrorMsg").show();
				    	return false;
				}
			}
		
			// Dont repeat && more than one time
			var values = myString.split("||");
			if(values.length > 2){
				$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.repetiveORValidation"/>');
		    	$("#"+id+"ErrorMsg").show();
		    	return false;
			}

			var offsetId = id.split("-DE")[0];
			var l = 0;
			var init;
			if(offsetId == "drOffset"){
				
					l = occurrences(myString,"|");
					if(l > 0 && l != 2){
						$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidORValidation"/>');
				    	$("#"+id+"ErrorMsg").show();
				    	return false;
					}
			}
		}
    
	return status;
}
	
    function columnsValidation(id , e){
		
		//keycode =8 backspace
		//keycode =13 enter
		//keycode =9 tab
		//keycode =37 left arrow
		//keycode = 39 right arrow
		//keycode = 44 comma
		var ret;
		var myString = $("#"+id).val();
		var keyCode =  e.which  ? e.which : e.keyCode;
		var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017

		if(parseInt(myString.length) > 0){
			var lastChar = myString[myString.length -1];
			if(lastChar == ',') {
				if(keyCode == 44){
					$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.commaValidation"/>');
			    	$("#"+id+"ErrorMsg").show();
			    	return false;
				}
			}
			
		} else {
			if(keyCode == 44){
				$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.commaValidation"/>');
		    	$("#"+id+"ErrorMsg").show();
		    	return false;
			}
		}

		if(btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End') {
			ret = true;
		} else {
			// Key code 39(for Single Qoute) is removed by Anil Kumar D for Mantis Id : 14088
			ret = ((keyCode >= 48 && keyCode <= 57) || (keyCode == 8)||(keyCode == 13)||(keyCode == 9) ||(keyCode == 44));//to allow only numbers
		}
			if(!ret){
		    	$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidInput"/>');
		    	$("#"+id+"ErrorMsg").show();	    	
		    }else{
		    	$("#"+id+"ErrorMsg").html('');
		    	$("#"+id+"ErrorMsg").hide();
		    }
			return ret;
		
	}
	
    // && validation for visa dr identifier and offset
 function validateOffsetCharecter(id , e){

		//keycode =8 backspace
		//keycode =13 enter
		//keycode =9 tab
		//keycode =37 left arrow
		//keycode = 39 right arrow
		//keycode = 46 delete
		//keyCode = 38 ampersand
		//keyCode = 124 pipe
		var ret ;
		var keyCode =  e.which  ? e.which : e.keyCode;
		//alert(keyCode);
		var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017
		if(btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End') {
			ret = true;
		} else {
			// Key code 39(for Single Qoute) is removed by Anil Kumar D for Mantis Id : 14088
			ret = ((keyCode >= 48 && keyCode <= 57) || (keyCode == 8)||(keyCode == 13)||(keyCode == 9) || (keyCode == 38) || (keyCode == 124));//to allow only numbers
		}
	    if(!ret){
	    	$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.invalidNumber"/>');
	    	$("#"+id+"ErrorMsg").show();	    	
	    }else{
	    	$("#"+id+"ErrorMsg").html('');
	    	$("#"+id+"ErrorMsg").hide();
	    }
		return ret;
		
	}
    
    
    
	function stringIdentifierValidaiton(id){
		$("#"+id+"ErrorMsg").html("");
		$("#"+id+"ErrorMsg").hide();
		
	}
	//modified by Nancy for multisupport in excel on 25-07-17//hemnnn
	function drTabExcelFileValidation(){
		var drResult = true;
		var totalrow = parseInt($("#fixedExcelDrTableId tbody tr").length);
		var lastrowid = parseInt($("#fixedExcelDrTableId tbody>tr:last").attr("id"));
		var multiFormatDataSupport = $.trim($("#multiFormatDataSupport").val());
		var rowId = [];
		var tempColumn = new Array();
		var tempColumnOrder = new Array();
		var tempRow = new Array();
		
			
		for( var i=1; i<=lastrowid; i++ ) {
			if ( $("#"+i).attr("id") == i) {
				
				if ( $.trim($("#sheetName-"+i).val()) == "" || $.trim($("#sheetName-"+i).val()) == null ) {
					$("#sheetName-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterSheetName"/>');
					$("#sheetName-"+i+"ErrorMsg").show();
					drResult =false;
				} else {
					$("#sheetName-"+i+"ErrorMsg").html("");
					$("#sheetName-"+i+"ErrorMsg").hide();
				} 
				if ( $.trim($("#templateId-"+i).val()) == "" ||  $.trim($("#templateId-"+i).val()) == null ) {
					$("#templateId-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectTemplateId"/>');
					$("#templateId-"+i+"ErrorMsg").show();
					drResult =false;
				} else {
					$("#templateId-"+i+"ErrorMsg").html("");
					$("#templateId-"+i+"ErrorMsg").hide();
				} 
				if(multiFormatDataSupport == "N"){
					if ( $.trim($("#drStartLineNo-"+i).val()) == "" || $.trim($("#drStartLineNo-"+i).val()) == null ) {
						$("#drStartLineNo-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterDrStartLineNo"/>');
						$("#drStartLineNo-"+i+"ErrorMsg").show();
						drResult =false;
					} else {
						$("#drStartLineNo-"+i+"ErrorMsg").html("");
						$("#drStartLineNo-"+i+"ErrorMsg").hide();
					} 
				}else if(multiFormatDataSupport == "Y"){
					
					//alert($('input[value='+'ABC'+']').length());

					if ( $.trim($("#orderOfExe-"+i).val()) == "" ||  $.trim($("#orderOfExe-"+i).val()) == null ) {
						$("#orderOfExe-"+i+"ErrorMsg").html('Select Order Of Execution');
						$("#orderOfExe-"+i+"ErrorMsg").show();
						drResult =false;
					} else {
						$("#orderOfExe-"+i+"ErrorMsg").html("");
						$("#orderOfExe-"+i+"ErrorMsg").hide();
					} 
					if ( $.trim($("#endText-"+i).val()) == "" || $.trim($("#endText-"+i).val()) == null ) {
						$("#endText-"+i+"ErrorMsg").html('Enter End Text');
						$("#endText-"+i+"ErrorMsg").show();
						drResult =false;
					} else if($.trim($("#endText-"+i).val()).indexOf("|") == -1 || $.trim($("#endText-"+i).val()).indexOf("|") == 0 || $.trim($("#endText-"+i).val()).indexOf("|") > 2 ){
						$("#endText-"+i+"ErrorMsg").html('Invalid End Text');
						$("#endText-"+i+"ErrorMsg").show();
						drResult =false;
					}else{
						var temp = $.trim($("#endText-"+i).val()).split("|");
						
						var ret = $.isNumeric(temp[0]); 
						if(ret){
							$("#endText-"+i+"ErrorMsg").html('Invalid Number in End Text');
							$("#endText-"+i+"ErrorMsg").show();
							drResult =false;
						}else if(!ret){
							var ret = $.isNumeric(temp[1]);
							if(ret){
								$("#endText-"+i+"ErrorMsg").html('Invalid Number in End Text');
								$("#endText-"+i+"ErrorMsg").show();
								drResult =false;
							}
						}else{
							
							$("#endText-"+i+"ErrorMsg").html("");
							$("#endText-"+i+"ErrorMsg").hide();
						}
						
					} 
					if ( $.trim($("#startText-"+i).val()) == "" || $.trim($("#startText-"+i).val()) == null ) {
						$("#startText-"+i+"ErrorMsg").html('Enter Start Text');
						$("#startText-"+i+"ErrorMsg").show();
						drResult =false;
					} else if($.trim($("#startText-"+i).val()).indexOf("|") == -1 || $.trim($("#startText-"+i).val()).indexOf("|") ==  0 || $.trim($("#startText-"+i).val()).indexOf("|") > 2){
						$("#startText-"+i+"ErrorMsg").html('Invalid Start Text');
						$("#startText-"+i+"ErrorMsg").show();
						drResult =false;
					}else{
						var temp = $.trim($("#startText-"+i).val()).split("|");
						
						var ret = $.isNumeric(temp[0]); 
						if(ret){
							$("#startText-"+i+"ErrorMsg").html('Invalid Number in Start Text');
							$("#startText-"+i+"ErrorMsg").show();
							drResult =false;
						}else if(!ret){
							var ret = $.isNumeric(temp[1]);
							if(ret){
								$("#startText-"+i+"ErrorMsg").html('Invalid Number in Start Text');
								$("#startText-"+i+"ErrorMsg").show();
								drResult =false;
							}
						}else{
							
							$("#startText-"+i+"ErrorMsg").html("");
							$("#startText-"+i+"ErrorMsg").hide();
						}
						
					}
					
				}
				
			}
		}
		
		if( drResult ) {
			//sheetName uniqueness validation  

			for ( var rowid = 1, j = 0; rowid <= lastrowid; rowid++) {
				if ($("#" + rowid + "").attr("id") == rowid) {
					tempColumn[j] = $.trim($("#sheetName-" + rowid + "").val());
					tempColumnOrder[j] = $.trim($("#orderOfExe-" + rowid + "").val());
					tempRow[j] = rowid;
				}
				j++;
			}
			if(multiFormatDataSupport == "N")	{
				for ( var i = 0; i < tempRow.length; i++) {
					var cells = new Array();
					var data = $("#fixedExcelDrTableId tr#" + tempRow[i] + "").map(	function(index, elem) {
						cells = $(this).find('.must');
						if( i != 0 ) {
							for ( var j = 0; j < i; j++) {
								if(drResult == true){
									var sheetNameA = tempColumn[i];
									var sheetNameB = tempColumn[j];
									
									if (sheetNameA == sheetNameB) {
										drResult = false;
										$(cells[0])	.html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.alreadyEnteredSheetName" />');
										$(cells[0])	.show();
									} else {
										$(cells[0]).html("");
										$(cells[0]).hide();
									}
								}
							}
						}
					});
										
				}
			}else if(multiFormatDataSupport == "Y"){
				for ( var i = 0; i < tempRow.length; i++) {
					var cells = new Array();
					var data = $("#fixedExcelDrTableId tr#" + tempRow[i] + "").map(	function(index, elem) {
						cells = $(this).find('.must');
						if( i != 0 ) {
							for ( var j = 0; j < i; j++) {
								if(drResult == true){
									var sheetNameA = tempColumn[i];
									var sheetNameB = tempColumn[j];
									var orderOfExeA = tempColumnOrder[i];
									var orderOfExeB = tempColumnOrder[j];
									
									if ((sheetNameA == sheetNameB) && (orderOfExeA== orderOfExeB)) {
										drResult = false;
										$(cells[4])	.html('Select Different Order');
										$(cells[4])	.show();
									} else {
										$(cells[4]).html("");
										$(cells[4]).hide();
									}
								}
							}
						}
					});
				}
			}
			
		}
		
		//Added by vinoth
		if(drResult) {
			for( var i=1; i<=lastrowid; i++ ) {
				if($('#toggle-two'+i).is(':checked')) {
					$('#toggle-two-data'+i).val('Y');
				}else {
					$('#toggle-two-data'+i).val('N');
				}
			}
		}
		return drResult;
	}
	
	//dr tab validation
	function drTabValidation(numberOfFormat, dataFormat){
		var drResult = true;
		var lastrowid = "";
		var totalrow = "";
		var fileType = $("#fileType").val(); //added by nancy
		
		for(var i=1;i<=numberOfFormat;i++){
			if($("#templateId-"+i+"").val() == ""){
				$("#templateId-"+i+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectTemplateId"/>');
				$("#templateId-"+i+"ErrorMsg").show();
				drResult = false;
			} else{
				$("#templateId-"+i+"ErrorMsg").html("");
				$("#templateId-"+i+"ErrorMsg").hide();
			}
		}
		
		//Template uniqueness validation  
		if(numberOfFormat > 1){
		var tempColumn = new Array();
		for (var j = 1; j <= numberOfFormat; j++) {
			tempColumn[j] = $("#templateId-" + j).val();
		}
			for (var i = 1; i <= numberOfFormat; i++) {
				if (i != 1) {
					for (var j = 1; j < i; j++) {
						if(drResult == true){
							
							var templateA = tempColumn[i];
							var templateB = tempColumn[j];
	// 						alert(templateA+" ---> "+templateB);
							if (templateA == templateB) {
								drResult = false;
								$("#templateId-" + i + "ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.alreadySelectedTemplateId"/>');
								$("#templateId-" + i + "ErrorMsg").show();
							} else {
								$("#templateId-" + i + "ErrorMsg").html("");
								$("#templateId-" + i + "ErrorMsg").hide();
							}
						}
					}
				}
			}
		} //if close(numberofFormat >1)
			
		
		for(var i=1;i<=numberOfFormat;i++){
			
			if(dataFormat == 'F'){
				var totalrow = parseInt($("#fixedDataRecordTableId-"+i+" tbody tr").length);
				var lastrowid = $("#fixedDataRecordTableId-"+i+" tbody>tr:last").attr("id");
			} else if(dataFormat == 'V'){
				var totalrow = parseInt($("#variableDataRecordTableId-"+i+" tbody tr").length);	
				var lastrowid = $("#variableDataRecordTableId-"+i+" tbody>tr:last").attr("id");
			} else if(dataFormat == 'K'){
				var totalrow = parseInt($("#keyBasedDataRecordTableId-"+i+" tbody tr").length);	
				var lastrowid = $("#keyBasedDataRecordTableId-"+i+" tbody>tr:last").attr("id");
			}
// 			alert("totalrow  :"+totalrow);  mohaan
			
			//for setting the template id value in hidden template Field
				var rowId = lastrowid.split("_");	
			for(var j=1;j<=parseInt(rowId[1]); j++){   // Fix for Mantis id - 13152 
				if( $("#DE"+i+"_"+j).attr("id") == "DE"+i+"_"+j ) {  
				$("#hiddenTemplateId-DE"+i+"_"+j).val($("#templateId-"+i).val());
				}
			}
			//working now 
			if(numberOfFormat == 1 && dataFormat == 'F' && totalrow == 1 && fileType != 'X'){   //modified  by Nancy for xml

				var lastrowid = $("#fixedDataRecordTableId-"+i+" tbody>tr:last").attr("id");
				
				var drIdentifier11 = $("#drIdentifier-"+lastrowid).val();
				var drOffset11 = $("#drOffset-"+lastrowid).val();
				$("#tempDrIdentifier").val(drIdentifier11); // Added by Mohan Raj.V to fix the Mantis issue id = 13601 
				if(drIdentifier11 == "" && drOffset11 != "" ){
					$("#drIdentifier-"+lastrowid+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterDrIdentifier"/>');
					$("#drIdentifier-"+lastrowid+"ErrorMsg").show();
					drResult = false;
				} else if(drIdentifier11 != "" && drOffset11 == "" ){
					$("#drOffset-"+lastrowid+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterDrOffset"/>');
					$("#drOffset-"+lastrowid+"ErrorMsg").show();
					drResult = false;
				} else if(drIdentifier11 == "" && drOffset11 == "" ){
					$("#drIdentifier-"+lastrowid+"ErrorMsg").html("");
					$("#drIdentifier-"+lastrowid+"ErrorMsg").hide("");
					$("#drOffset-"+lastrowid+"ErrorMsg").html("");
					$("#drOffset-"+lastrowid+"ErrorMsg").hide();
				} 
				
			} else {
					
				var rowId = lastrowid.split("_");		//to get the last row of the table (DE1_7)	7 <--
				
				for(var j=1;j<=parseInt(rowId[1]);j++){ 
					if ($("#DE"+i+"_"+j).attr("id") == "DE"+i+"_"+j) {   //row id available check
						if( $("#drIdentifier-DE"+i+"_"+j).val() == ""){//Modified By Nancy for Mantis Id : 13601  // trim removed by Mohan Raj.V to fix the issue
							$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterDrIdentifier"/>');
							$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").show();
							drResult = false;
						} else {
							$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").html("");
							$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").hide();
						}		
						if(fileType != "X"){//added by nancy on 11-05-16 to remove mandatory check of drOffset for xml 
						if($("#drOffset-DE"+i+"_"+j).val() == ""){ 
							$("#drOffset-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterDrOffset"/>');
							$("#drOffset-DE"+i+"_"+j+"ErrorMsg").show();
							drResult = false;
						} else {
							$("#drOffset-DE"+i+"_"+j+"ErrorMsg").html("");
							$("#drOffset-DE"+i+"_"+j+"ErrorMsg").hide();
						}
						}
						
						if(dataFormat == 'K'){
							if($("#parentChildIndicator-DE"+i+"_"+j).val() == ""){
								$("#parentChildIndicator-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectParentChildIndicator"/>');
								$("#parentChildIndicator-DE"+i+"_"+j+"ErrorMsg").show();
								drResult = false;
							} else {
								$("#parentChildIndicator-DE"+i+"_"+j+"ErrorMsg").html("");
								$("#parentChildIndicator-DE"+i+"_"+j+"ErrorMsg").hide();
								if($("#parentChildIndicator-DE"+i+"_"+j).val() == 'C'){
									if($.trim($("#parent-DE"+i+"_"+j).val()) == "") {
										$("#parent-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterParent"/>');
										$("#parent-DE"+i+"_"+j+"ErrorMsg").show();
										drResult = false;
									} else {
										$("#parent-DE"+i+"_"+j+"ErrorMsg").html("");
										$("#parent-DE"+i+"_"+j+"ErrorMsg").hide();
									}
								} else {
									$("#parent-DE"+i+"_"+j+"ErrorMsg").html("");
									$("#parent-DE"+i+"_"+j+"ErrorMsg").hide();
								}
							}
							// columns is not mandatory
							/* if($("#columns-DE"+i+"_"+j).val() == "") {
								$("#columns-DE"+i+"_"+j+"ErrorMsg").html("Enter the Columns");
								$("#columns-DE"+i+"_"+j+"ErrorMsg").show();
								drResult = false;
							} else {
								$("#columns-DE"+i+"_"+j+"ErrorMsg").html("");
								$("#columns-DE"+i+"_"+j+"ErrorMsg").hide();
							} */
							
							if($("#columns-DE"+i+"_"+j).val() != "") {
								var columnString = $("#columns-DE"+i+"_"+j).val() ;
								if(columnString[0] == ','){
									$("#columns-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.commaValidation"/>');
									$("#columns-DE"+i+"_"+j+"ErrorMsg").show();
									drResult = false;	
								} 
								if(columnString[columnString.length -1] == ','){
									$("#columns-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.commaValidation"/>');
									$("#columns-DE"+i+"_"+j+"ErrorMsg").show();
									drResult = false;
								}
								if(columnString[0] != ',' && columnString[columnString.length -1] != ','){
									$("#columns-DE"+i+"_"+j+"ErrorMsg").html("");
									$("#columns-DE"+i+"_"+j+"ErrorMsg").hide();
								}
								
							} else {
								$("#columns-DE"+i+"_"+j+"ErrorMsg").html("");
								$("#columns-DE"+i+"_"+j+"ErrorMsg").hide();
							} 
							
							if($("#stringIdentifier-DE"+i+"_"+j).val() == ""){
								$("#stringIdentifier-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterStringIdentifier"/>');
								$("#stringIdentifier-DE"+i+"_"+j+"ErrorMsg").show();
								drResult = false;
							} else {
								$("#stringIdentifier-DE"+i+"_"+j+"ErrorMsg").html("");
								$("#stringIdentifier-DE"+i+"_"+j+"ErrorMsg").hide();
							}
							//DR Identifier and  offset && and || validation addded by banu
							if(drResult){
								var ampIdendifierStatus = true;
								var ampOffsetStatus = true;
								var orIdendifierStatus = true;
								var orOffsetStatus = true;
								ampIdendifierStatus = ampersandValidation("drIdentifier-DE"+i+"_"+j);
								ampOffsetStatus = ampersandValidation("drOffset-DE"+i+"_"+j);
								orIdendifierStatus = orConditionValidation("drIdentifier-DE"+i+"_"+j);
								orOffsetStatus = orConditionValidation("drOffset-DE"+i+"_"+j);
								
								if(ampIdendifierStatus == true && ampOffsetStatus == true){
									
									var offsetValuesForOR = $("#drIdentifier-DE"+i+"_"+j).val().split("||");
									var offsetValuesForAmp = $("#drIdentifier-DE"+i+"_"+j).val().split("&&");
									if(offsetValuesForOR.length >1 && offsetValuesForAmp.length > 1){
										$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.InvalidAmpersandORCombination"/>');
										$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").show();
										drResult = false;
									}else{
									
										var drValues = $("#drIdentifier-DE"+i+"_"+j).val().split("&&");
										var offsetValues = $("#drOffset-DE"+i+"_"+j).val().split("&&");
										var ampIndrIdy = "0";
										var ampInOffset = "0";
										if(drValues.length >1)
											ampIndrIdy = "1";
										if(offsetValues.length >1)
											ampInOffset = "1";
										if(ampIndrIdy == "0" && ampInOffset == "1"){
											$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterAmpersand"/>');
											$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").show();
											drResult = false;
										}else if(ampIndrIdy == "1" && ampInOffset == "0"){
											$("#drOffset-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterAmpersand"/>');
											$("#drOffset-DE"+i+"_"+j+"ErrorMsg").show();
											drResult = false;
										}else{
											drResult = true;
										}
									}
									if(drResult == true){
										if(orIdendifierStatus == true && orOffsetStatus == true){
											
											var offsetValuesForOR = $("#drOffset-DE"+i+"_"+j).val().split("||");
											var offsetValuesForAmp = $("#drOffset-DE"+i+"_"+j).val().split("&&");
											if(offsetValuesForOR.length >1 && offsetValuesForAmp.length > 1){
												$("#drOffset-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.InvalidAmpersandORCombination"/>');
												$("#drOffset-DE"+i+"_"+j+"ErrorMsg").show();
												drResult = false;
											}else{
											
												var drValues = $("#drIdentifier-DE"+i+"_"+j).val().split("||");
												var offsetValues = $("#drOffset-DE"+i+"_"+j).val().split("||");
												var orIndrIdy = "0";
												var orInOffset = "0";
												if(drValues.length >1)
													orIndrIdy = "1";
												if(offsetValues.length >1)
													orInOffset = "1";
												if(orIndrIdy == "0" && orInOffset == "1"){
													$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterOR"/>');
													$("#drIdentifier-DE"+i+"_"+j+"ErrorMsg").show();
													drResult = false;
												}else if(orIndrIdy == "1" && orInOffset == "0"){
													$("#drOffset-DE"+i+"_"+j+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.enterOR"/>');
													$("#drOffset-DE"+i+"_"+j+"ErrorMsg").show();
													drResult = false;
												}else{
													drResult = true;
												}
											}
											
										}else{
											drResult = false;
										}
									}
								}else{
									drResult = false;
								}
								
   					         }
						} //end of K
				}//end if for row id check
				} //for loop close
			} //main else close
				
			//Added by vinoth
			if($('#toggle-two'+i).is(':checked')) {
				$('#toggle-two'+i).val('Y');
			}else {
				$('#toggle-two'+i).val('N');
			}
			
			} //end of for loop dynamic table validations
		return drResult;
	}
	
	function fnTemplateErrorMsg(id){
		var template = $("#"+id).val();
		if(template == ""){
			$("#"+id+"ErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectTemplateId"/>');
			$("#"+id+"ErrorMsg").show();
		} else {
			$("#"+id+"ErrorMsg").html("");
			$("#"+id+"ErrorMsg").hide();
		}
	}
	//Added by Nancy for multisupport in excel on 25-07-17//hemnnn
	function fnOrderOfExeErrorMsg(id){
		var orderOfExe = $("#"+id).val();
		if(orderOfExe == ""){
			$("#"+id+"ErrorMsg").html('Select Order Of Execution');
			$("#"+id+"ErrorMsg").show();
		} else {
			$("#"+id+"ErrorMsg").html("");
			$("#"+id+"ErrorMsg").hide();
		}
	}
	function fnStartTextErrorMsg(id){
		var startText = $("#"+id).val();
		if(startText == ""){
			$("#"+id+"ErrorMsg").html('Enter Start Text');
			$("#"+id+"ErrorMsg").show();
		} else {
			$("#"+id+"ErrorMsg").html("");
			$("#"+id+"ErrorMsg").hide();
		}
	}
	function fnEndTextErrorMsg(id){
		var endText = $("#"+id).val();
		if(endText == ""){
			$("#"+id+"ErrorMsg").html('Enter End Text');
			$("#"+id+"ErrorMsg").show();
		} else {
			$("#"+id+"ErrorMsg").html("");
			$("#"+id+"ErrorMsg").hide();
		}
	}
	function footerTypeValidation (){
		var iteration = $("#controlTagCount").val();
		var iteration1 = $("#numberOfFormat").val();
		
		 if(iteration != ""){
				for ( var i = 0; i < iteration; i++ ) {
					
					var fileType = $.trim($("#fileType").val());
					//footer Type validation	
					var footertype =$("#footerType").val();
					if(footertype != ""){
					if( footertype == 'F'){
						$("#controlDataColumnPosition-"+i+"").attr("disabled" , "disabled");
						$("#controlDataFromPosition-"+i+"").attr("disabled" , false);
						$("#controlDataToPosition-"+i+"").attr("disabled" , false);
						$("#controlDataColumnPosition-"+i+"").val("");
						$("#controlDataColumnPosition-"+i+"ErrorMsg").html("");
					}else{
						$("#controlDataFromPosition-"+i+"").attr("disabled" , "disabled");
						$("#controlDataToPosition-"+i+"").attr("disabled" , "disabled");
						$("#controlDataColumnPosition-"+i+"").attr("disabled" , false);
						$("#controlDataFromPosition-"+i+"").val("");
						$("#controlDataToPosition-"+i+"").val("");
						$("#controlDataFromPosition-"+i+"ErrorMsg").html("");
						$("#controlDataToPosition-"+i+"ErrorMsg").html("");
					    } 
					} else {
						$("#footerTypeErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectFooterType" />');
					}
					//added by nancy for xml
					   if(fileType == 'X'){
					   $("#controlDataFromPosition-"+i+", #controlDataToPosition-"+i+"").keypress(function(e){  //, #controlDataColumnPosition-"+i+"  //added by nancy
						   var specialKeys = new Array();
					        specialKeys.push(8); //Backspace
					        specialKeys.push(13); //Enter
					        specialKeys.push(46);
					        var keyCode = e.which ? e.which : e.keyCode
							var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017
							if((btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End')){
								ret = true;
							}else{
								var ret = ((keyCode >= 48 && keyCode <= 57) || $.inArray(keyCode, specialKeys) != -1 || (keyCode == 9)||(keyCode == 37) ||(keyCode == 39) || (keyCode == 97));
								 
							}
							return ret;				
						});
						
					  }else{
						  $("#controlDataFromPosition-"+i+", #controlDataToPosition-"+i+", #controlDataColumnPosition-"+i+"").keypress(function(e){  
							   var specialKeys = new Array();
						        specialKeys.push(8); //Backspace
						        specialKeys.push(13); //Enter
						        specialKeys.push(46);
						        var keyCode = e.which ? e.which : e.keyCode
								var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017
								if((btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End')){
									ret = true;
								}else{
									var ret = ((keyCode >= 48 && keyCode <= 57) || $.inArray(keyCode, specialKeys) != -1 || (keyCode == 9)||(keyCode == 37) ||(keyCode == 39) || (keyCode == 97));
									 
								}
								return ret;
								
							});
					  }
					
					
				}
				
		   }
	  }
	  function controlTypeVal(id, rowNo){ 
		var iteration1 = $("#numberOfFormat").val();
			var val = $("#"+id).val();
 			$("#controlType-"+rowNo+"ErrorMsg").html("");
 			for(var z=0; z<iteration1; z++ ){
 			if(val == 'cnt'){  
				$("#controlDataRecordField-"+rowNo+"-"+z+"ErrorMsg").html("");
				$("#controlDataRecordField-"+rowNo+"-"+z).attr("disabled" , true);
				$("#controlDataRecordField-"+rowNo+"-"+z).val("");
			}else{
				$("#controlDataRecordField-"+rowNo+"-"+z).attr("disabled"  , false);
			}
 			}
		}  
	   	function fromPositionValidation(id,rowNo){
	   	//keycode =9 tab
	   	
	   	var keyCode =  e.which  ? e.which : e.keyCode;
		var btnCode = e.code;		//Added by Anil Kumar D for Mantis Id : 14017
		if(btnCode == 'KeyA' || btnCode == 'Delete' || btnCode == 'ArrowUp' || btnCode == 'ArrowLeft' || btnCode == 'ArrowRight' || btnCode == 'ArrowDown' || btnCode == 'Home' || btnCode == 'End') {
			ret = true;
		} else {
			// Key code 39(for Single Qoute) is removed by Anil Kumar D for Mantis Id : 14088
			ret = ((keyCode == 9));//to allow only numbers
		}
	   	if(ret){
	   		var fromPost = parseInt($("#"+id).val());
	   		var toPost = parseInt($("#controlDataToPosition-"+rowNo+"").val());
	   		if(fromPost > toPost){
	   			$("#controlDataFromPosition-"+rowNo+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.invalidFromPosition"/>');
	   			return;
	   		}else{
	   			$("#controlDataFromPosition-"+rowNo+"ErrorMsg").html("");
	   		}
	   		if(fromPost <= toPost){
	   			$("#controlDataToPosition-"+rowNo+"ErrorMsg").html("");
	   		}
	   	}
	   		
	   	}
	   	function toPositionValidation(id,rowNo){
	   		var toPost = parseInt($("#"+id).val());
	   		var fromPost = parseInt($("#controlDataFromPosition-"+rowNo+"").val());
 
 	   			if(fromPost > toPost){
	   				$("#controlDataToPosition-"+rowNo+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.invalidToPosition"/>');
	   	   			return;
	   			}else{
	   				$("#controlDataToPosition-"+rowNo+"ErrorMsg").html("");
	   			}
 	   			if(fromPost <= toPost){
 	   			$("#controlDataFromPosition-"+rowNo+"ErrorMsg").html("");
 	   			}
	    	}
	   	function columnPositionVal(id,rowNo){
 	   		var val = parseInt($("#"+id).val());
	   		if(val == 0){
	   			$("#controlDataColumnPosition-"+rowNo+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.invalidNumber"/>');
	   			return;
	   		}else{
	   			$("#controlDataColumnPosition-"+rowNo+"ErrorMsg").html("");
	   		}
	   	}
	   	function recordFieldValidation(id, rowNo,j){
	    			$("#controlDataRecordField-"+rowNo+"-"+j+"ErrorMsg").html("");
	    	}
	   	
	   	function checkFieldFunction(id,rowNo,j){
	   		
	   		var val = $("#"+id).val();
	   		if(val !=""){
	   			$("#controlCheckConstant-"+rowNo+"-"+j).attr("disabled" ,false);
	   		}else{
	   			$("#controlCheckConstant-"+rowNo+"-"+j).attr("disabled" ,"disabled");
	   			$("#controlCheckConstant-"+rowNo+"-"+j).val("");
	   			$("#controlCheckConstant-"+rowNo+"-"+j+"ErrorMsg").html("");  
	   			
	    		}
	   		
	   	}

		//added by nancy for footer
		function savePopUpWindow(id, i) {
			
			var footerChildResult = true;
			var iteration = $("#numberOfFormat").val();
			
		 	var footerType = $("#footerType").val();
		 	var count = 0;
		 	
	      //control Type validation
		  	for(var j=0; j<iteration ; j++){
	 		   var controlType = $("#controlType-"+i+"").val();
	 		   var recordFields = $("#controlDataRecordField-"+i+"-"+j+"").val();
	 		   var checkFields = $("#controlCheckField-"+i+"-"+j+"").val();
	 		   var controlCheckConstants = $("#controlCheckConstant-"+i+"-"+j+"").val();
	 		   if( controlType == 'sum'){
	 			   if( recordFields == ""){
 				   		$("#controlDataRecordField-"+i+"-"+j+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.emptyRecordFields"/>');
 				   		//count++;
 				  		footerChildResult = false;
		   			}
	 		  } 
	 		  if( checkFields != ""){
	 			   if((controlCheckConstants == "")||(controlCheckConstants == null)){
	 			   $("#controlCheckConstant-"+i+"-"+j+"ErrorMsg").html('<spring:message code="RCN.ReconMaster.InputFileConfiguration.InputFileFooter.Validation.emptyControlCheckConstant"/>');
	 			  $("#controlCheckConstant-"+i+"-"+j+"ErrorMsg").show();
	 			   //count++;
	 			   footerChildResult = false;
	 			   }else{
	 				  $("#controlCheckConstant-"+i+"-"+j+"ErrorMsg").html('');
	 				 $("#controlCheckConstant-"+i+"-"+j+"ErrorMsg").hide();
	 			   }
	 		   }else{
	 	 			$("#controlCheckConstant-"+i+"-"+j+"ErrorMsg").html("");
	 	 			$("#controlCheckConstant-"+i+"-"+j+"ErrorMsg").hide();
	 		   }
		   		
			}
	      
			
		   for(var j=0,k=1; j<iteration ; j++,k++){
		   	  if( footerChildResult ){
			   
				$("#hiddenControlDataRecordField-"+i+"-"+j+"").val($("#controlDataRecordField-"+i+"-"+j+"").val());
				$("#hiddenControlCheckField-"+i+"-"+j+"").val($("#controlCheckField-"+i+"-"+j+"").val());
				$("#hiddenControlCheckConstant-"+i+"-"+j+"").val($("#controlCheckConstant-"+i+"-"+j+"").val());
				$("#hiddenTemplateFields-"+i+"-"+j+"").val($("#templateId-"+k+"").val());
				var val = $("#templatecheck-"+i).val();
				$("#templatecheck-"+i+"ErrorMsg").html('');
	 			$("#templatecheck-"+i+"ErrorMsg").hide();
			    }
			}
		   	if( footerChildResult ){
		  	 	$("#DemomyModal").hide();
		  	 
		   	    }
		}
	
		
		// Added by Mohan raj.V to fix the pop issue 
		//hemnnn
		function fn_fileTypeOnchange(element){
// 			var  prev_val = element.oldValue;
			var conf = true;
// 	alert(element.value);
			var dataFormat = $.trim($("#dataFormat").val());
			var numberOfFormat = $.trim($("#numberOfFormat").val());
			if(dataFormat != "" && dataFormat != null){
				conf = confirm('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.confirmAlertFileTypeChange" />');
				 if(conf){
// 					 $("#hiddenFileType").val(element.value); // Added by Mohan Raj.V to Fix the CLM issue id = 15876
					//added by nancy	
					 $("#fileHeaderAvailable").val("");
					 $("#headerKeyCount").val("");//nancy
					 $("#headerKeyCount").attr("readonly",false);
					 $("#dynamicDataLineDiv").hide();					 
					 $("#DataRecordDivId").hide();
					 $("#DataRecordDivId").empty();//Nancy
					 $("#showaddbtn").hide();//Nancy
					 $("#dynamicFooterDiv").hide();
					 $("#footerAvailable").val("");
					 $("#footerAvailable").attr("disabled",false);
					 $("#controlTagCount").val("");
					 $("#footerTypeErrorMsg").html();
					 $("#footerTypeErrorMsg").hide();
					 $("#footerType").val("");
					 $("#footerLength").val("");
					 $("#dataFormat").val("");
					 $("#multiFormatDataSupport").val("");
					 $("#numberOfFormat").val("");
					 if(dataFormat == 'V') {
						 $("#blockSizeAvailable").val("");
						 $("#blockSize").val("");
						 $("#varaiableLengthHiddenFieldDiv").hide();
					 }
				 } else {
					 /* alert($("#hiddenFileType").val()); */
					 $("#fileType").val($("#hiddenFileType").val());
				 }
			}
			
			 $("#hiddenFileType").val(element.value);
			 
			var val = $("#fileType").val();
			
			if(val == null || val == ""){
				$("#fileTypeErrorMsg").html('<spring:message code="rcn.reconMaster.inputFileConfiguration.defineInputFileConfiguration.selectFileType" />');
			}else if(val == 'D'){
				//enable
				$("#delimiter").removeAttr("disabled");
				$("#fileTypeErrorMsg").html("");
			}else{
				//disabled
				$("#delimiter").attr("disabled", "disabled");
				$("#fileTypeErrorMsg, #delimiterErrorMsg").html("");
				$("#delimiter").val("");
			}
			//var xsdFileName = $("#xsdFileName").val();
			//XML added by Nancy
			 if(val == 'X'){
				 $("#xsdFileNameDiv").show();
				 //13-07
				 $.ajax({
					url 		: "getXSD.rcn",
				  	type		: "POST" ,
				  	dataType	: 'json', 
					contentType	: 'application/json',
					mimeType	: 'application/json',
	 				async		: false
						 
	    		   }).done(function(response){
		    			  $("#xsdFileName").find('option').remove().end().append('<option value="">Not Selected</option>').val('');
		    			  //alert(response); //  OBJECT
		    			  $.each(response , function(index , value){
	 	    				 //alert(index +" :"+value); // 0 -files List
							 //alert(index);
	    							$('<option>').val(index).text(value).appendTo("#xsdFileName"); 
		    				 });
		    			  });
				 
				
			}else{
				$("#xsdFileNameDiv").hide();
				 $("#xsdFileName").val("");
			}			
//			if( val == 'E' && !(prev_val == 'E') ) {
			if( val == 'E' && !conf ) {  // Added by Mohan Raj.V to Fix the CLM issue id = 15876
				// to avoid clearing drTab values if fileType doesnot change from Excel to other
			}else if( val == 'E' ) {//hemnnn
				$("#dataFormat").val("F");
				var dataFormat = $("#dataFormat").val();
				var noOfFormat = "";
				//$("#multiFormatDataSupport").attr("disabled", true); 
				$("#dataFormat").attr("disabled", true);
				$("#controlTagCount").attr("disabled",true);
				//$("#footerAvailable").val('N');
				//$("#footerAvailable").attr("disabled",true);
				//fn_generatingTable(dataFormat, noOfFormat);  // function to generate dynamic table
			} else {
				if( conf ){  // Added by Mohan Raj.V to fix the CLM issue id s.no .16
					$("#dataFormat").val("");
					$("#dataFormat").attr("disabled", false);
					$("#multiFormatDataSupport").attr("disabled", false);
				}
			}
		
				//added by nancy
// 				if( val == 'X' && !(prev_val == 'X' ) ) {
			if( val == 'X'){
					$("#dataFormat").val("F");
					$("#dataFormat").attr("disabled", true);
					//added by nancy for xml (only one template should be configured)on 11-05-16:starts
					$("#multiFormatDataSupport").val("N");
					$("#multiFormatDataSupport").attr("disabled",true);
					$("#numberOfFormat").val(1);
					fn_generatingTable("F", 1);  // function to generate dynamic table
					//added by nancy for xml (only one template should be configured)on 11-05-16:ends
					$("#footerType").val("D");
					$("#footerType").attr("disabled", "disabled");
					//fn_generatingTable(dataFormat, noOfFormat);  // function to generate dynamic table
				}
				
}
//multem by Nancy//hemnnn
function callPlusRowFun(){
	
	var numberOfFormat = $.trim($("#numberOfFormat").val());
	var dataFormat = $.trim($("#dataFormat").val());
	 var fileType = $("#fileType").val();
	 //Added by Nancy for multisupport in excel on 25-07-17
	 if(fileType == "E"){
		 $("#numberOfFormat").val("");
		 $("#numberOfFormat").attr("readonly" , true);
		 fn_generatingTable(dataFormat, 1);
	 }else{
		 $("#numberOfFormat").val(++numberOfFormat);
		 var numberOfFormat = $.trim($("#numberOfFormat").val());
		 fn_generatingTable(dataFormat, numberOfFormat);
	 }
	if(numberOfFormat>2){
		$("#showminusbtn").show();
	}else{
		$("#showminusbtn").hide();
	}
	
}	

function callMinusRowFun(){
	
	var dataFormat = $.trim($("#dataFormat").val());
	var numberOfFormat = $.trim($("#numberOfFormat").val());
	
	if(dataFormat == "F"){
		$("#fixedDynamicDiv-"+numberOfFormat).remove();
	}else if(dataFormat == "V"){
		$("#VaraiableDynamicDiv-"+numberOfFormat).remove();
	}else if(dataFormat == "K"){
		$("#keyBasedDynamicDiv-"+numberOfFormat).remove();
	}
	$("#numberOfFormat").val(--numberOfFormat);
	var numberOfFormat = $.trim($("#numberOfFormat").val());
	if(numberOfFormat>2){
		$("#showminusbtn").show();
	}else{
		$("#showminusbtn").hide();
	}
	//alert(numberOfFormat)
	//fixedDynamicDiv-
	//fn_generatingTable(dataFormat, numberOfFormat);
}
//Added by Nancy for multisupport in excel on 25-07-17//hemnnn
function fnStartTxtVal(id,e){
	
	var keyCode =  e.which  ? e.which : e.keyCode;
	var btnCode = e.code;
	var ret = true;
	var startOrEndText = $("#"+id).val();
	//alert(startOrEndText.indexOf("|"));
	//alert(startOrEndText);
	if(startOrEndText.length < 2 ){
		ret=alphaValidation(id,e);
		if(!ret){
			return false;
		}
	}else if(startOrEndText.length == 2 && startOrEndText.indexOf("|") == -1){
		startOrEndText = startOrEndText+"|";
		$("#"+id).val(startOrEndText);
		ret=true;
		
	} else if(startOrEndText.indexOf("|") >= 1){
		
		if(keyCode == 124){
			return false;
		} 
	}
	return ret; 
}
//nancy:ends
		
 </script>
 
 <body>
	 <div class="container gray-border-bottom">
     	<ol class="breadcrumb col-lg-11">
	        <li class="active">Config</li>
	        <li><a href="<%=request.getContextPath()%>/redirectInputFileConfig.rcn">Input File Configuration</a></li>
       		<li class="active">Add</li>
	     </ol>
	     <div class="col-lg-1 text-right"> </div>
 	</div>

	<h4><spring:message code='master.inputFileConfig.addInputFileConfig.Heading'/></h4>
		<jsp:include page="/WEB-INF/views/ums/layout/ResponsePage.jsp" />
		   	<form:form name="inputFileConfigForm" id = "inputFileConfigForm" autocomplete="off" method="post" commandName="configForm" onFocus="parent_disable()" onclick="parent_disable()">
		
		                    <article class="col-xs-12">
		                        <div class="wizard inactive-tab-wizard">
		                            <ul class="nav nav-tabs">
			                              <li class="active"><a class="tab1"><spring:message code='master.inputFileConfig.fileNameHeading'/></a></li>
			                              <li><a class="tab2"><spring:message code='master.inputFileConfig.headerDetailsHeading'/></a></li>
			                              <li><a class="tab3"><spring:message code='master.inputFileConfig.dataRecordHeading'/></a></li>
			                              <li><a class="tab4"><spring:message code='master.inputFileConfig.footerDetailsHeading'/></a></li>
		                            </ul>
		                            <div class="tabresp tab-content">
		                            	<!--File name tab  tab1 starts -->
		                                <div class="tab-pane fade in active" id="tab1">
		                                    <div class="form-inline">
		                                        
		                                        <div class="form-group col-lg-12">
													
													<!-- For File Name -->
													<label class="col-lg-3"> <spring:message code='masters.inputFileConfig.fileName'/><span class = "must">*</span>
													</label> 
														<span class="col-lg-3"> 
															<spring:bind path="configForm.fileName">
																<input type="text" id="fileName" class="formtextbox" maxlength="30"
																	value="<c:out value="${status.value}"/>"
																	name="<c:out value="${status.expression }"/>" />
															</spring:bind><br/>
															<span id="fileNameErrorMsg" class="must"></span>
														</span>
														
													<!-- File Format (*) | file Type  -->
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.fileType' /> 
														<span class="must">*</span>
													</label> 
													<span class="col-lg-3">
														<form:select path="fileType" id="fileType"  onchange="fn_fileTypeOnchange(this)" style="width:170px">
															<form:option value="">Not Selected</form:option>
															<form:options items="${fileType }" />
														</form:select><br/>
														
														<span id="fileTypeErrorMsg" class="must"></span>
													</span>
													<input type="hidden" id="hiddenFileType" name="hiddenFileType">
												</div>
		                                        
		                                        <div class="form-group col-lg-12">
		                                        
		                                           <!-- File Description -->
		                                           <label class="col-lg-3">
		                                          		<spring:message code='masters.inputFileConfig.fileDescription' />
		                                          		<span class="must">*</span>
		                                          </label>
		                                          <span class="col-lg-3">
		                                          	 <spring:bind path="configForm.fileDescription">
											       		<input type="text" id="fileDescription"  class="formtextbox" maxlength="25" onkeypress ='return alphaNumericValidation(this.id,event)' 
											       			value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }" />" />
										       		</spring:bind><br/>
													<span id="fileDescriptionErrorMsg" class="must"></span>
		                                          </span>
		
		                                         <!-- Delimiter -->
													<label class="col-lg-3">
														<spring:message code='masters.inputFileConfig.delimiter' />
													</label> 
													<span class="col-lg-3" >
														<form:select path="delimiter" id="delimiter" disabled="true" name="delimiter" style="width:170px">
															<form:option value="">Not Selected</form:option>
															<form:option value="\\t">Tab</form:option>
															<form:option value=",">Comma</form:option>
															<form:option value=":">Colon</form:option>
															<form:option value=";">Semicolon</form:option>
															<form:option value="\\s">Space</form:option>
															<form:option value="|">Pipe</form:option>
														</form:select><br/>
														
														<span id="delimiterErrorMsg" class="must"></span>
													</span>
		                                        </div>
		                                        <div class="form-group col-lg-12">
		                                        	<!-- File Name Convention Format -->
													<label class="col-lg-3"> 
														<spring:message  code='masters.inputFileConfig.fileNameConventionFormat' />
													</label> 
													<span class="col-lg-3"> 
														<spring:bind path="configForm.fileNameConventionFormat">
															<input type="text" class="formtextbox" id="fileNameConventionFormat" readonly="readonly" maxlength="25"
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
																
															<input type="button" class="btn gray-btn btn-sm" onclick="OpenWindow('Recon')" value=""  
																data-toggle="modal" data-target="#define-constant" id = 'fileNameConventionFormatBtnId'>
														</spring:bind><br/>
														
														<span id="fileNameConventionFormatErrorMsg" class="must"></span>
													</span>
													<!-- File Name Max Length -->
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.fileNameMaxLength' />
													</label> 
													<span class="col-lg-3"> 
														<spring:bind path="configForm.fileNameMaxLength">
															<input type="text" class="formtextbox" id="fileNameMaxLength" maxlength="2" style="width:170px"
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind><br/>
														
														<span id="fileNameMaxLengthErrorMsg" class="must"></span>
													</span>
													
											     </div> 
												
												
												 <div class="form-group col-lg-12">
												 
													 <!-- Define Constant -->
													<%-- <label class="col-lg-3">
														<spring:message code='masters.inputFileConfig.defineConstant' />
													</label>  --%>
													<span class="col-lg-3" style="display: none;"> 
														<spring:bind path="configForm.defineConstant">
															<input type="text" class="formtextbox" id="defineConstant" readonly="readonly" maxlength="25"
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind><br/>
														<span id="defineConstantErrorMsg" class="must"></span>
													</span>
													<!-- hiddenformatvalue -->
													<span class="col-lg-3" style="display: none;"> 
														<spring:bind path="configForm.hiddenNamingConvention">
															<input type="text" class="formtextbox" id="hiddenNamingConvention" readonly="readonly" maxlength="25"
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind><br/>
													</span>
													
													<!--FTP Type (File Path)-->
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.filePath' />
														<span class = "must">*</span>
													</label> 
													<span class="col-lg-3">
														<div style="display: none;" id="fileServerDiv">
															<form:select path="fileFtpPath" id="filePath">
																<form:option value="E">EXTERNAL FTP SERVER</form:option>
																<form:option value="I">INTERNAL FTP SERVER</form:option>
															</form:select>
														</div>
		
														<div id="filePathLocationDiv">
															<spring:bind path="configForm.fileLocalPath">
																<input type="text" class="formtextbox" id="filePathLocation" name="fileLocalPath" maxlength="100" value=""
																	value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
															</spring:bind>
														</div>
		
														<span id="filePathErrorMsg" class="must"></span>
													</span>
													<!--File Location -->
													<label class="col-lg-3">
														<spring:message code='masters.inputFileConfig.fileLocation' />
														<span class="must">*</span>
													</label> 
													
													<span class="col-lg-3">
	<!-- 												value="F"  Commented to disable -->
															
														<input type="radio"  name="fileLocation" value="F" id="fileLocationFtp"  onchange="showFTP()"  /> <!-- Modified By Nancy on 26-04-2016 -->
														<B>FTP</B>
														
														<input type="radio"  name="fileLocation" value="" id="fileLocationLocal" onchange="showFTP()"  />
														<B>Local</B>
													
													<div>
														<span id="fileLocationErrorMsg" class="must"></span>
													</div>
													</span>
												</div>
												
												<div class= "form-group col-lg-12">
													<!-- Duplicate Check On File Name -->
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.duplicateCheckOnFileName' />
														<span class="must">*</span>
													</label> 
													<span class="col-lg-3">
														<form:select path="duplicateCheckOnFileName" id="duplicateCheckOnFileName" > <!-- class="select_styled" -->
															<form:option value="N">NO</form:option>
															<form:option value="Y">YES</form:option>
														</form:select><br/>
														
														<span id="dupCheckOnFileNameErrorMsg" class="must"></span>
													</span>
													<!-- XSD File Name --> <!-- added by Nancy -->
													 <div id="xsdFileNameDiv" style='display:none;'>
													<label class="col-lg-3"> 
													   <!--  XSD File Path -->
													  <spring:message code='masters.inputFileConfig.xsdFilePath' />
														<span class="must">*</span>
													</label>
													
																	
													   <form:select path="xsdFileName" id="xsdFileName" style="width:170px">
														<form:option value="">Not Selected</form:option>
<%-- 														<form:options items="${xsdFileNameList}"/> --%>
													  </form:select> 
												
												   <div>
												   <span id="xsdFileNameErrorMsg"  class="must"></span>
												   </div>
												   
												   </div> 
												</div>
												<!-- added by nancy for dependency -->
										    <div class= "form-group col-lg-12">
												<span class="col-lg-3">
														
															<label><spring:message code='masters.inputFileConfig.dependency'/></label>
															</span>
															<span class="col-lg-3">
															<input type="checkbox"  name="dependency" value="N" id="dependency" onclick="checkDependency(this)" onchange="fn_checkboxOnchange(this)" />
															</span>
															
														<%-- </spring:bind> --%>
														
												<!--  Dependency File List -->
												 <div id="dependencyDiv"  style='display:none;' > 
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.dependencyFile'/>
														<span class="must">*</span>
													</label>
													<form:select path="dependencyFileNameId" name = "dependencyFileName"  id="dependencyFileName"  style="width:170px" >
														<form:option value="">Not Selected</form:option>
														<form:options items="${dependencyFileName}"/>
													</form:select>
													<div>
														<span id="dependencyFileNameErrorMsg"  class="must"></span>
													</div>
												</div>
											</div> 
												<!--	FTPServerName Added by Nancy on 26-04-2016-->
												
												<div>
												<span class="col-lg-3">
													<label>Settlement Required</label>
												</span>	 
												<span class="col-lg-3">
													<input type="checkbox" id="settlmntCheck" value='N' name="settlmntCheck" onchange="checkSettelment(this)" >
												</span>
												<div id="FTPNameDiv" style='display:none;' >
													<label class="col-lg-3"> 
													   <!--  FTP Name  -->
													  <spring:message code='recon.core.dataElement.ftpServerName'/>
														<span class="must">*</span>
													</label>
													<form:select path="ftpServerName"  id="ftpServerName" style="width:170px">
														<form:option value="">Not Selected</form:option>
														<form:options items="${ftpServerNameList}"/>
													</form:select> 
												
												    <div>
												         <span id="ftpServerNameErrorMsg"  class="must"></span>
												   </div>
												   <div class= "form-group col-lg-12">
												   <span class="col-lg-6"> 
													</span>
													<label class="col-lg-3"> 
														<spring:message code='recon.core.dataElement.ftpfilepath'/>
														<span class="must">*</span>
													</label>
														<input type="text" class="formtextbox" id="ftpFilePath" name="ftpFilePath" maxlength="100" value="" style="width:170px"/>
													<div>
														<span id="ftpFilePathErrorMsg" class="must"></span>
													</div>
													</div>
												</div>
												</div>
											</div>			
		                                                                                 
		                                    <div class="panel-footer">
		                                       <input type="button" value="Next " 
													name="fileNameDtlsButton" id="fileNameDtlsButton" class="btn btn-primary next-v-tab">
		                                    </div>     
		                                </div>
		                           		<!-- Tab1 Ends -->
		
		                           		<!-- Tab2 Starts -->
                                <div class="tab-pane" id="tab2">
		                                   <div class="form-inline">
		                                        
		                                        <div class="form-group col-lg-12">
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.fileHeaderAvailable' /> 
														<span class="must">*</span>
													</label> 
													<span class="col-lg-3"> 
														<form:select id="fileHeaderAvailable" path="fileHeaderAvailable">
															<form:option value="">Not Selected</form:option>
															<form:option value="Y">YES</form:option>
															<form:option value="N">NO</form:option>
														</form:select><br /> 
														<span id="fileHeaderAvailableErrorMsg" class="must"></span>
													</span>
				
														<!-- Header Block  Size-->
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.headerBlockSize' />
													</label> 
													<span class="col-lg-3"> 
														<spring:bind path="configForm.headerBlockSize">
															<input type="text" class="formtextbox" id="headerBlockSize" maxlength="20"
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind><br /> 
														
														<span id="headerBlockSizeErrorMsg" class="must"></span>
													</span>
												</div>
												
												<div class="form-group col-lg-12">
													<!-- Header Key Count --> 
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.headerKeyCount' />
													</label> 
													<!-- Multiple Header Data Count -->
													<%-- <label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.headerKeyCount' />
													</label>  --%>
													<span class="col-lg-3"> 
														<spring:bind path="configForm.headerKeyCount">
															<input type="text" class="formtextbox" id="headerKeyCount"  maxlength="2" 
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind><br /> 
														
														<span id="headerKeyCountErrorMsg" class="must"></span>
													</span>
												
													<!-- Header With Dr -->
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.headerWithDr' />
														<!-- <span class="must">*</span> -->
													</label> 
													<span class="col-lg-3"> 
														<spring:bind path="headerWithDr">
															<select id="headerWithDr" disabled="disabled" name = 'headerWithDr'>
																<option value="">Not Selected</option>
																<option value="Y">YES</option>
																<option value="N">NO</option>
															</select>
														</spring:bind><br /> 
													<span id="headerWithDrErrorMsg" class="must"></span>
		
													</span>
												</div>
												
												<!-- For header dynamic fields based on no of lines-->
												<div class="col-lg-10 col-lg-offset-1"  id = "dynamicDataLineDiv" style="display:none;"> <br>
													<table id="headerDynamicTableId" class="table table-hover table-striped table-bordered" cellspacing="0" >
						                                <thead class="table-head">
						                                    <tr>
						                                        <th><spring:message code='masters.inputFileConfig.headerKeyFromPosition' />
						                                        </th>
						                                        <th><spring:message code='masters.inputFileConfig.headerKeyToPosition' />
						                                        </th>
						                                        <th><spring:message code='masters.inputFileConfig.fileHeaderBeginsWithCheck' />
						                                        </th>
						                                        <th><spring:message code='masters.inputFileConfig.fileHeaderBeginsWithConst' />
						                                        </th>
						                                        <th><spring:message code='masters.inputFileConfig.fileHeaderDataType' />
						                                        </th>
						                                        <th><spring:message code='masters.inputFileConfig.fileHeaderDataFormat' />
						                                        </th>
						                                        <th><spring:message code='masters.inputFileConfig.fileHeaderDuplicateValue' />
						                                        </th>
						                                        <th><spring:message code='masters.inputFileConfig.fileHeaderSequenceCheck' />
						                                        </th>
						                                        <th><spring:message code='masters.inputFileConfig.fileHeaderLinePosition' />
						                                        </th>
						                                    </tr>
						                                </thead>
						                                <tbody class="row" id = "dynamicDataLineInnerDiv">
						                                    <tr>
						                                        <td></td>
						                                        <td></td>
						                                    </tr>
						                                </tbody>
		                            				</table>
												</div>
		                                        	
		                                   </div>
		                                   
		                                   <div class="panel-footer">
		                                   		<input name="" type="button" class="btn btn-primary previous-v-tab" value="Previous">&nbsp;&nbsp;&nbsp;
		                                        <input type="button" value="Next "	name="headerDetailsBtn" id="headerDetailsBtnId" class="btn btn-primary next-v-tab">
		                                   </div>
		                                </div>
		                                <!-- Tab2 Ends -->
		                                
                                <!-- Tab3 Starts  data record-->
                                <div class="tab-pane" id="tab3">
		                                   <div class="form-inline">
		                                   		
		                                   		<div class ="col-lg-8 col-lg-offset-2" align = "center">
		                                   			<!-- Data Format -->
		                                   			<label class="col-lg-6">
		                                   				<spring:message code='masters.inputFileConfig.dataFormat'/><span class="must">*</span>
		                                   			</label>
		                                   			<span class="col-lg-3">
		                                   				<spring:bind path="configForm.dataFormat">
		                                   					<select id="dataFormat" name="dataFormat">
		                                   						<option value="">Not Selected</option>
		                                   						<option value="F">Fixed Length</option>
		                                   						<option value="V">Variable Length</option>
		                                   						<option value="K">Key Based</option>
		                                   					</select>
		                                   				</spring:bind>
		                                   				<div id="dataFormatErrorMsg" class="must"></div>
		                                   			</span>
		                                   		</div>
		                                   		
		                                   		<div class="form-group col-lg-12" id="varaiableLengthHiddenFieldDiv" style="display:none;">
		                                   			<label class='col-lg-3'>
														<spring:message code='masters.inputFileConfig.blockSizeAvailable'/>
													</label>
													<span class='col-lg-3'>
														<spring:bind path='configForm.blockSizeAvailable'>
															<select name='blockSizeAvailable' id='blockSizeAvailable' onChange = 'blockSizeValidation();'>
																<option value=''>Not Selected</option>
																<option value='Y'>Yes</option>
																<option value='N'>No</option>
															</select>
														</spring:bind>
													<span id='blockSizeAvailableErrorMsg' class='col-lg-12 must'></span>
													</span>
													<label class='col-lg-3'>
														<spring:message code='masters.inputFileConfig.blockSize'/>
													</label>
													<span class='col-lg-3'>
														<spring:bind path='configForm.blockSize'>
															<input name='blockSize' id='blockSize' type='text' maxlength='6' readonly = 'readonly' onkeypress ='return NumericValidation(this.id,event)' class='formtextbox'/>
														</spring:bind>
													<span id='blockSizeErrorMsg' class='col-lg-12 must'></span> 
													</span>
		                                   		</div>
		                                   		
		                                   		<div class = "col-lg-12">
		                                   			<!-- Multiple Format Data Record Support -->
		                                   			<label class="col-lg-3">
		                                   				<spring:message code='masters.inputFileConfig.multiFormatDataSupport'/>
		                                   			</label>
		                                   			<span class="col-lg-3">
		                                   				<spring:bind path="configForm.multiFormatDataSupport">
		                                   					<select id="multiFormatDataSupport" name="multiFormatDataSupport">
		                                   						<option value="">Not Selected</option>
		                                   						<option value="Y">Yes</option>
		                                   						<option value="N">No</option>
		                                   					</select>
		                                   				</spring:bind>
		                                   				<div id="multiFormatDataSupportErrorMsg" class="must"></div>
		                                   			</span>
		                                   			
		                                   			<!-- Number of Format -->
		                                   			<label class="col-lg-2">
		                                   				<spring:message code='masters.inputFileConfig.numberOfFormat'/>
		                                   			</label>
		                                   			<span class="col-lg-2">
		                                   				<spring:bind path="configForm.numberOfFormat">
		                                   					<input id="numberOfFormat" name="numberOfFormat" type="text" readonly="readonly" onkeypress ="return NumericValidation(this.id,event)" class="formtextbox" maxlength="1" />
		                                   				</spring:bind> <br />
		                                   				<span id="numberOfFormatErrorMsg" class="must"></span>
		                                   			</span>
		                                   			<!-- Added By Nancy on 05-10-16 for multem -->
		                                   			<div>
			                                   			<span id="showaddbtn" style="display:none;">
			                                   				<span class="glyphicon glyphicon-plus" id="add" onclick="callPlusRowFun()" aria-hidden="true"></span>
			                                   			</span>
			                                   			<span id="showminusbtn" style="display:none;">
			                                   				<span class="glyphicon glyphicon-minus" id="minus" onclick="callMinusRowFun()" aria-hidden="true"></span>
			                                   			</span>
		                                   			</div>
		                                   		</div>
		                                   		<!-- <div class="form-group col-lg-6 table table-hover table-striped table-bordered" id = "DataRecordDivId" style="display:none;"><br/> -->
		                                   		<div class="form-group col-lg-6 table table-hover" id = "DataRecordDivId" style="display:none;"><br/>
		                                   		</div>
		                                   </div>
		                                   <div style = "display :none;" >
		                                   			<form:select path="templateId" id="hiddenTemplateDiv" name ="hiddenTemplateDiv">
		<%--                                    				<form:option value="">Not Selected</form:option> --%>
		                                   				<form:options items = "${templateResult}"/>
		                                   			</form:select>
		                                   		</div>
		                                   		<input  type="hidden" id="tempDrIdentifier" name="tempDrIdentifier" /> <!--  Added by Mohan Raj.V to fix the Mantis issue id = 13601 --> 
		                                   
		                                   <div class="panel-footer">
		                                    	<input name="" type="button" class="btn btn-primary previous-v-tab" value="Previous">&nbsp;&nbsp;&nbsp;
		                                        <input type="button" value="Next "	name="dataRecordNextButton" id="dataRecordNextButton" class="btn btn-primary next-v-tab">
		                                    </div> 
		                           		</div>
		                                <!-- Tab3 Ends -->
		                                
                                <!-- Tab4 Starts  footer tab -->
                                <div class="tab-pane" id="tab4">
		                                    <div class="form-inline">
		                                    
		                                         <div class="form-group col-lg-12">
		                                         <!-- Footer Available -->
		                                          <label class="col-lg-3">
		                                          		<spring:message code='masters.inputFileConfig.footerAvailable' />
														<span class="must">*</span>
													</label>
		                                          <span class="col-lg-3">
			                                          	<form:select path="footerAvailable"  id="footerAvailable">
												       		<form:option value="">Not Selected</form:option>
												       		<form:option value="Y">YES</form:option>
															<form:option value="N">NO</form:option>
											       		</form:select><br /> 
														
														<span id="footerAvailableErrorMsg" class="must"></span>
		                                          </span>
		                                          
		                                          <!-- Footer Type-->
		                                          <label class="col-lg-3">
		                                          	<spring:message code='masters.inputFileConfig.footerType' />
		                                          </label>
		                                          <span class="col-lg-3">
		                                              <form:select path="footerType" id="footerType"  disabled="true" onchange = "footerTypeValidation()">
											       			<form:option value="">Not Selected</form:option>
											       			<form:option value="F">Fixed Length</form:option>
											       			<form:option value="D">Delimited</form:option>
											     	</form:select><br /> 
											     	<span id="footerTypeErrorMsg" class="must"></span>
		                                          </span>     
		                                        </div>
		                                        
		                                         <div class="form-group col-lg-12">
		                                         	<!-- Footer Begins Constant -->
													<label class="col-lg-3"> 
														<spring:message code='masters.inputFileConfig.footerBeginsConstant' />
													</label> 
													<span class="col-lg-3"> 
														<spring:bind path="configForm.footerBeginsConstant">
															<input type="text" class="formtextbox" id="footerBeginsConstant" readonly="true" maxlength="50" onkeypress ='return alphaNumericValidation(this.id,event)' 
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind><br/>
														
														<span id="footerBeginsConstantErrorMsg" class="must"></span>
													</span>
													 <!-- Footer Length -->
													<label class="col-lg-3">
														<spring:message code='masters.inputFileConfig.footerLength' />
													</label> 
													<span class="col-lg-3"> 
														<spring:bind path="configForm.footerLength">
															<input type="text" class="formtextbox" id="footerLength" readonly="true" maxlength="6"
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind>
														<div id="footerLengthErrorMsg" class="must"></div>
													</span>
												</div>
												
												 <div class="form-group col-lg-12">
		                                        	 
		                                         	<!-- No. Of Control Tags in Footer  -->
		                                          	<label class="col-lg-3">
		                                          		<spring:message code='masters.inputFileConfig.controlTagCount' />
		<!--                                           		<span class="must">*</span> -->
		                                          	</label>
		                                          	<span class="col-lg-3">
		                                             	<spring:bind path="configForm.controlTagCount">
															<input type="text" class="formtextbox" id="controlTagCount"  readonly="true" maxlength="2"
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind>
														
														<div id="controlTagCountErrorMsg" class="must"></div>
		                                          	</span>
		                                          	<!-- added by Anil kumar to store menu Access Id -->
		                                          	    <%-- <spring:bind path="configForm.accessID">
															<input type="hidden" class="formtextbox" id="accessID"  readonly="true" maxlength="10"
																value="<c:out value="${status.value}"/>" name="<c:out value="${status.expression }"/>" />
														</spring:bind> --%>
		                                        </div>
		                                        
												</div>
		                                       
		                                        <div class="form-group " id= "dynamicFooterDiv" style = "display: none;"><br/>
															<table border="1" align="center" id="tableFieldDef" class="table table-hover table-striped table-bordered ">
																<thead class="table-head">
																	<tr>	   
																	  <th><spring:message code='masters.inputFileConfig.controlType'/></th>
																	  <th><spring:message code='masters.inputFileconfig.controlDataFromPosition'/></th>
																	  <th><spring:message code='masters.inputFileConfig.controlDataToPosition'/></th>
																	  <th><spring:message code='masters.inputFileConfig.controlDataColumnPosition'/></th>
																	  <th></th>
																	  <%-- <th><spring:message code='masters.inputFileConfig.controlDataRecordsField'/></th>
																	  <th><spring:message code='masters.inputFileConfig.controlCheckFields'/></th>
																	  <th><spring:message code='masters.inputFileConfig.controlCheckConstant'/></th> --%>
											                	   </tr> 
																 </thead>
																<tbody class="row" id = "noOfLinesFooterInnerDiv">
						                                 		   <tr >
						                                 		   
						                                   		   </tr>
						                                		</tbody>
															 </table>
				 								  </div>
		         	                              
		                                    <div class="panel-footer">
		                                    	<input name="" type="button" class="btn btn-primary previous-v-tab" value="Previous">&nbsp;&nbsp;&nbsp;
		                                        <input type="button" value="Submit" name="footerDetailsBtnId" id="footerDetailsBtnId" class="btn btn-primary ">
		                                    </div>     
		                                    
		                                </div>
		                            	<!-- Tab4 Ends -->
		                            </div>
		                        </div>
		                    </article>
		                    <p class="text-center">
		                    	<input type="button" value="Cancel" name="cancelButton" id="cancelButton" class="btn btn-primary gray-btn">
		                    </p>
		    </form:form>
		    
		    
		    <div class="modal" id="DemomyModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="display: none">
			<div class="modal-dialog-alert col-lg-9 col-lg-offset-1">
				<div class="modal-content col-lg-12 col-lg-offset-1">
					<div class="modal-header" style="text-align: left">
						<button type="button" class="close" data-dismiss="modal" onclick="closebox(this,0)">
							<span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
						</button>
						<h4 class="modal-title" id="myModalLabel">
							<spring:message code='recon.core.dataElement.cntroldtl'/>
						</h4>
					</div>
					
					<div id="hiddenActionDiv" class="form-group col-lg-6 col-lg-offset-2"  style="display: none;">
					</div>   <!-- hiddenActionDiv close -->
					
			</div>
			
			</div>
		</div>
		    
		    
		    
		    </body>