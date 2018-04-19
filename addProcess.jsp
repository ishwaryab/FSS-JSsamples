<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script type="text/javascript">

$(document).ready(function()
{
	//---------------------Show hide divs -------------------------------------------------//
	var mode="${MODE}";
	if(mode=="Add")
	{
		$('#rankFields1,#rankFields2,#rankFields3,#rankFields4').multiselect({buttonWidth: '180px',maxHeight: 400,dropUp: true,numberDisplayed: 1});
		
		$('#fileTypesDiv,#templatesDiv,#rankFieldsDiv,#dataTablesDiv,#masterDiv').hide();
		$('#f1,#f2,#f3,#f4').hide();
		$('#ft1,#ft2,#ft3,#ft4').hide();
		
		$('#deliveryChannel').multiselect({buttonWidth: '180px',maxHeight: 400,numberDisplayed: 1});
		
	}else if(mode=="Edit")
	{	
		$('#rankFields1,#rankFields2,#rankFields3,#rankFields4').multiselect({buttonWidth: '180px',maxHeight: 400,numberDisplayed: 1});
		$('#deliveryChannel').multiselect({buttonWidth: '180px',maxHeight: 400,numberDisplayed: 1});
		$('#deliveryChannel').multiselect('select', '${processDefEdit.deliveryChannel}'.split(','));
		//--------------------Loading Rank Fields-----------------------------//
		//Rank Field 1
		loadRankFields('${processDefEdit.fileType1}','1');
		$('#rankFields1').multiselect('select', '${processDefEdit.rankFields1}'.split(','));
		//Rank Field 2
		loadRankFields('${processDefEdit.fileType2}','2');
		$('#rankFields2').multiselect('select', '${processDefEdit.rankFields2}'.split(','));

		var inputCount="${processDefEdit.inputCount}";
		if(inputCount=="3" || inputCount=="4")
		{
			//Rank Field 3
			loadRankFields('${processDefEdit.fileType3}','3');
			$('#rankFields3').multiselect('select', '${processDefEdit.rankFields3}'.split(','));
		}	
		if(inputCount=="4")
		{
			//Rank Field 4
			loadRankFields('${processDefEdit.fileType4}','4');
			$('#rankFields4').multiselect('select', '${processDefEdit.rankFields4}'.split(','));
		}
	}	
	else 
	{	
		$('#rankFields1,#rankFields2,#rankFields3,#rankFields4').multiselect({buttonWidth: '180px',maxHeight: 400,numberDisplayed: 1});
		$('#deliveryChannel').multiselect({buttonWidth: '180px',maxHeight: 400,numberDisplayed: 1});
		var inputCount="${processDefEdit.inputCount}";
		for(var i=1;i<=inputCount;i++)
		{
			var value=$('#rankFields'+i).find('option').length+" selected";
			$('#rankField'+i+'Span').find('.multiselect-selected-text').html(value)
		}	
		$('#deliveryChannel').multiselect('select', '${processDefEdit.deliveryChannel}'.split(','));
	}	

	//-------Clear Error Messages -------------------------------------------------------//
	$('#rankFields1,#rankFields2,#rankFields3,#rankFields4,#masterTemplate,#matchingType,#channel').change(function(e)
	{
		if(this.value!=null && this.value!="")
			$('#'+this.id+'Div').html('');
	});		
	
	$('#retentionPeriod,#retentionVolume').keyup(function(e)
	{
		if(this.value!=null && this.value!="")
			$('#'+this.id+'Div').html('');
	});		

	
	//---------------- Process Name Validation ----------------------------------------------//
	$('#processName').keyup(function(e)
	{
	    var yourInput = $(this).val();
		if(yourInput == "") 
		{	
			$('#processNameDiv').html("");
		}else 
		{
			re=/^[A-Za-z0-9]+$/;
			var isSplChar = re.test(yourInput);
			if(isSplChar==false)
			{
				var no_spl_char = yourInput.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
				$(this).val(no_spl_char);
				$('#processNameDiv').html('<spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.AlphanumericProcessName"/>');
				$('#submitButton').prop('disabled',true);
			}else
			{
				$('#processNameDiv').html('');
				duplicateCheckProcessName();
			}
		}
	});
	
	//--------------------Common Match Flag-------------------------//
	$('#commonMatch').click(function(e)
	{
		if($('#commonMatch').is(':checked'))
		{	
			$('#commonMatchFlag').val('Y');
			$('#identicalMatchingAlert').html('User has enabled same matching fields!');
		}	
		else
		{	
			$('#commonMatchFlag').val('N');
			$('#identicalMatchingAlert').html('');
		}	
	});
	
	
});

function duplicateCheckProcessName()
{
    $.ajax({
			url: 'processNameDuplicateCheck.rcn',
			type: 'POST',
			data: 'processName=' + $('#processName').val(),
			cache: false,
		})			          
		.done(function(data) 
		{
			 
			var duplicateName = JSON.parse(data);
		    $('#processNameDuplicateCheck').val(data);
		 
			if(duplicateName === "true")
			{
				 $('#processNameDiv').html('<spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.ExistProcessName"/>');
				 $('#submitButton').prop('disabled',true);					
			}else
			{
				 $('#processNameDiv').html(' ');
				 $('#submitButton').prop('disabled',false);
			}		    	  			       
		});
} 

function clrTemplateValues(value) 
{
	$('#submitButton').prop('disabled',false);
	$('#fileType1,#fileType2,#fileType3,#fileType4').val('');
	$('#fileType1Stage,#fileType2Stage,#fileType3Stage,#fileType4Stage,#reconTypeDiv').html('');

}

function showFileTypesTemplates() 
{
	var count = $('#inputCount').val();
	
	if(count!="")
	{
		$('#fileTypesDiv,#templatesDiv,#rankFieldsDiv,#dataTablesDiv').show();
		$('#f1,#f2,#ft1,#ft2').show();
		$('#f3,#f4,#ft3,#ft4,#rf3Div,#rf4Div,#dt3Div,#dt4Div').hide();
		$('#masterDiv').hide();
		
		$('#file1Div,#file2Div,#file3Div,#file4Div').html('');
		$('#fileType1Div,#fileType2Div,#fileType3Div,#fileType4Div,#masterTemplateDiv').html('');
		$('#rankFields1Div,#rankFields2Div,#rankFields3Div,#rankFields4Div').html('');
		$('#inputCountDiv').html('');
		
		
		if(count == 3 || count == 4)
		{
			$('#f3,#ft3,#rf3Div,#dt3Div').show();
			$('#file3,#fileType3').val('');
			$("#fileType3Stage").html("");
			$('#masterDiv').show();
		}	
		if(count==4)
		{
			$('#f4,#ft4,#rf4Div,#dt4Div').show();
			$('#file4,#fileType4').val('');
			$("#fileType4Stage").html("");
			$('#masterDiv').show();
		}	
/* -------------------------------------------------------------------------------------------- */			
		if(count==2)
		{	
			var tempId3= $('#fileType3').val();
			if(tempId3!=null && tempId3!="")
			{
				$("#masterTemplate option[value="+tempId3+"]").remove();
				$("#fileType3").children('option:not(:first)').remove();
			}
		}	
		
		if(count==2 || count==3)
		{	
			var tempId4= $('#fileType4').val(); 
			if(tempId4!=null && tempId4!="")
			{
				$("#masterTemplate option[value="+tempId4+"]").remove();
				$("#fileType4").children('option:not(:first)').remove();
			} 
		}	
	}else 
	{
		
		$('#fileTypesDiv,#templatesDiv,#rankFieldsDiv,#dataTablesDiv,#masterDiv').hide();
		$('#rankFields1Div,#rankFields2Div,#rankFields3Div,#rankFields4Div').html('');
		$('#file1,#file2,#file3,#file4').val('');
		$("#fileType1Stage").html("");
		$("#fileType2Stage").html("");
		$("#fileType1,#fileType2,#fileType3,#fileType4").children('option').remove();
		$('<option>').val("").text("Not Selected").appendTo("#fileType1,#fileType2,#fileType3,#fileType4")
	}
}

	
function loadTemplateDetails(id,templateId) 
{
	$('#'+templateId+"Stage").html('');
	var fileId= $("#"+id).val();
	if(fileId!="")
	{
		$("#"+id+"Div").html('');
		$.ajax({
			url : "getTemplates.rcn?file="+fileId,
			type : 'POST',
			cache : false,

		}).done(function(response) 
		{
			$("#"+templateId).children('option:not(:first)').remove();
		  	$.each(response , function(index , value){
				$('<option>').val(index).text(value).appendTo("#"+templateId);
		  	});
		});
	}else
		$("#"+templateId).children('option:not(:first)').remove();
}
	 

function loadMasterTemplate()
{
	var flag=true;
	var inputCnt=$('#inputCount').val();
	for(var i=1;i<=inputCnt;i++)
	{
	  var templateValue=$('#fileType'+i).val();
	  if(templateValue==null || templateValue=="")
	  {
		 flag=false;
		 break;
	  }
	}	
	$("#masterTemplate").children('option:not(:first)').remove();
	if(flag)
	{
		for(var i=1;i<=inputCnt;i++)
		{
			var IntInd ="${InterchangeIndicatorMap}".split(',');
			for(var i=1;i<=inputCnt;i++)
			{
				var value=$('#file'+i).val();
				if ($.inArray(value, IntInd) == -1) 
					$('<option>').val(i).text($('#fileType'+i+' option:selected').text()).appendTo("#masterTemplate");
				else
					$('#InchgInd').val(i);
			}	
		}	
	}
}
 
 
function MasterTemp(fileId,templateId,templatevalue,rankFieldId)
{
	var reconType=$('#reconType').val();
	var input=$('#inputCount').val();
	var fileType=$('#'+fileId).val();
		
	if(reconType!="")
	{
		if(templatevalue!="")
		{
			$('#'+templateId+'Div').html('');
			
			$.ajax({
	           url: 'checkDataTableAvailability.rcn',
	           type: 'POST', 
	           data : { "templateType":templatevalue,"fileType":fileType,"reconType":reconType}, 
	           cache: false,
	           
	         })			          
	         .done(function(data) 
	         {
	        	 var flag=data.split("|")[1];
	        	 var tableName=data.split("|")[0];
	        	 if(flag=="-1")
	        	 {
	        		 $('#'+templateId+"Stage").html(tableName+" <br> does not exist");	
	        		 $('#'+templateId+"hid").val('0')
	        		 $('#submitButton').prop('disabled',true);
	        		 $("#masterTemplate").children('option:not(:first)').remove();
	        	 }else if(flag=="1")
		         {	 
			         $('#'+templateId+"hid").val('1')
			         $('#'+templateId+"Stage").html(tableName);
		        	}
	        	 
	        	 if(input==2)
	        	{
	        		 if($('#fileType1hid').val()==1 && $('#fileType2hid').val()==1)
	        			 $('#submitButton').prop('disabled',false);
	        	}else if(input==3)
	        	{
	        		 if($('#fileType1hid').val()==1 && $('#fileType2hid').val()==1 && $('#fileType3hid').val()==1)
	        			 $('#submitButton').prop('disabled',false);
	        	}else if(input==4)
	        	{
	        		 if($('#fileType1hid').val()==1 && $('#fileType2hid').val()==1 && $('#fileType3hid').val()==1 && $('#fileType4hid').val()==1)
	        			 $('#submitButton').prop('disabled',false);
	        	}
	        	 if($('#submitButton').is(':disabled')==false)
	        	{	 
	        		 if(input==3 || input==4)
						loadMasterTemplate();
	        		 
	        		 loadRankFields(templatevalue,rankFieldId);
	        	}  
	         }); 
		}else
		{	
			$('#'+templateId+"Stage").html('');
			$("#masterTemplate").children('option:not(:first)').remove();
		}	
	}else
	{
		$("#masterTemplate").children('option:not(:first)').remove();
		$('#reconTypeDiv').html('<spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyReconType"/>');
		$('#'+templateId).val("");
	}	
		
}

function loadRankFields(value,id)
{
	$('#rankFields'+id).children('option').remove();
	$('#rankFields'+id).multiselect('destroy');
	
	if(value!=null && value!="")
	{	
		$.ajax({
			url: 'getColumnsForRankFields.rcn',
			type: 'POST',
			data: {"templateId":value},
			cache: false,
			async:false,
		})			          
		.done(function(data) 
		{
			 var jsonList = JSON.parse(data);
 			 $.each(jsonList,function(key,val) 
 		     {
 				 $('<option>').val(val).text(val).appendTo('#rankFields'+id);
          	 });
		});
	}	
	
	$('#rankFields'+id).multiselect({buttonWidth: '180px',maxHeight: 400,dropUp: true,numberDisplayed: 1});
}


function AddEdit() 
{
	
	var flag = true;
	var mode=$('#mode').val();
	var inputCount = $('#inputCount').val();
	
	//Add Page Validation
	if(mode=="Add")
	{	
		var processName = $('#processName').val();
		var reconType= $('#reconType').val();
		var matchingType= $('#matchingType').val();
		var period = $('#retentionPeriod').val();
		var volume = $('#retentionVolume').val();
		var channel = $('#channel').val();
		var matchtype=$('#matchingType').val();
		var deliveryChannel=$('#deliveryChannel').val(); //dhana priyanga
		if(processName==null || processName=="")
		{
			$('#processNameDiv').html(' <spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyProcessName"/> ');
			flag=false;
		}	
		if(inputCount==null || inputCount=="")
		{
			$('#inputCountDiv').html('<spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyInputCount"/> ');
			flag=false;
		}	
		if(channel==null || channel=="")
		{
			$('#channelDiv').html('<spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyChannel"/> ');
			flag=false;
		}
		if(reconType==null || reconType=="")
		{
			$('#reconTypeDiv').html('<spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyReconType"/> ');
			flag=false;
		}
		if(matchingType==null || matchingType=="")
		{
			$('#matchingTypeErrorMsg').html('<spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyMatchingType"/> ');
			flag=false;
		}
		
		if(period==null || period=="" || period.trim()=="")
		{
			$('#retentionPeriodDiv').html(' <spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyRetentionPeriod"/> ');
			flag=false;
		}else if(!checkOnlyNumber(period))
		{
			$('#retentionPeriodDiv').html('Only Numbers are allowed!');
			flag=false;
		}	
			
		if(volume==null || volume=="" || volume.trim()=="")
		{
			$('#retentionVolumeDiv').html(' <spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyRetentionVolume"/> ');
			flag=false;
		}else if(!checkOnlyNumber(volume))
		{
			$('#retentionVolumeDiv').html('Only Numbers are allowed!');
			flag=false;
		}
		
		if(matchtype==null || matchtype=="")
		{
			$('#matchingTypeDiv').html(' <spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyMatchingType"/> ');
			flag=false;
		}
		
		if(inputCount!=null && inputCount!="")
		{
			for(var i=1;i<=inputCount;i++)
			{
				//File Type Validation
				var fileTypeVal=$('#file'+i).val();
				if(fileTypeVal==null || fileTypeVal=="")
				{
					$('#file'+i+'Div').html('Select the File Type '+i);
					flag=false;
				}	
				
				//Template Validation
				var templateVal=$('#fileType'+i).val();
				if(templateVal==null || templateVal=="")
				{
					$('#fileType'+i+'Div').html('Select the Template '+i);
					flag=false;
				}
				
				//Rank Field Validation
				var rankFieldVal=$('#rankFields'+i).val();
				if(rankFieldVal==null || rankFieldVal=="")
				{
					$('#rankFields'+i+'Div').html('Select the Matching Field '+i);
					flag=false;
				}
			}	
			
			//Master Template Validation
			if(inputCount=="3" || inputCount=="4")
			{
				var masterTemp=$('#masterTemplate').val();
				if(masterTemp==null || masterTemp=="")
				{
					$('#masterTemplateDiv').html('<spring:message code="RCN.ReconMaster.ProcessConfiguration.Process.Validation.EmptyMasterTemplate"/>');
					flag=false;
				}
			}	
		}	
		
		if(deliveryChannel==null || deliveryChannel==""){
			$("#deliveryChannelDiv").html('<spring:message code="RCN.ReconMaster.Dispute.Validation.EmptyDeliveryChannel"/>');
			flag=false;
		}
		//File Type Duplicate Check
		if(flag)
		{
			$('#file1Div,#file2Div,#file3Div,#file4Div').html('');
			for(var i=1;i<=inputCount;i++)
			{
				for(var j=1;j<=inputCount;j++)
				{
					if(i!=j)
					{
						if($('#file'+i).val()==$('#file'+j).val())
						{
							$('#file'+j+'Div').html('Should Not be Same FileType');
							flag=false;
							break;
						}	
					}
				}
			}	
		}	
	}	
	//Edit Page Validation
	else if(mode=="Edit")
	{
		for(var k=1;k<=inputCount;k++)
		{
			//Rank Field Validation
			var rankFieldVal=$('#rankFields'+k).val();
			if(rankFieldVal==null || rankFieldVal=="")
			{
				$('#rankFields'+k+'Div').html('Select the Matching Field '+k);
				flag=false;
			}
		}	
	}

	//After Successful Validation Either Add or Edit Opertion will be performed
	if(flag)
	{	
	     if(mode=="Add")
        	document.createProcess.action="addProcessDef.rcn";
	     else
        	document.createProcess.action="editProcessDef.rcn";
	     
        document.createProcess.submit(); 
	}else
		return flag; 
} 
		
function ResetProcess() 
{
	$('#submitButton').prop('disabled',false);
	$('#fileTypesDiv,#templatesDiv,#rankFieldsDiv,#dataTablesDiv,#masterDiv').hide();
	$('#processName,#inputCount,#reconType,#matchingType,#retentionPeriod,#retentionVolume,#channel').val('');
	$('#processNameDiv,#inputCountDiv,#reconTypeDiv,#matchingTypeDiv,#retentionPeriodDiv,#retentionVolumeDiv,#channelDiv,#identicalMatchingAlert').html('');
	$('#commonMatch').prop('checked',false);
	//File Types,Temapltes and Master Template
	$('#file1,#file2,#file3,#file4').val('');
	$("#fileType1,#fileType2,#fileType3,#fileType4,#masterTemplate").children('option').remove();
	$('<option>').val("").text("Not Selected").appendTo("#fileType1,#fileType2,#fileType3,#fileType4,#masterTemplate");
	$('#fileType1Stage,#fileType2Stage,#fileType3Stage,#fileType4Stage,#masterTemplateDiv').html('');
	//Rank Fields
	$('#rankFields1Div,#rankFields2Div,#rankFields3Div,#rankFields4Div').html('');
	$('#rankFields1,#rankFields2,#rankFields3,#rankFields4').children('option').remove();
	$('#rankFields1,#rankFields2,#rankFields3,#rankFields4').multiselect('destroy');
	$('#rankFields1,#rankFields2,#rankFields3,#rankFields4').multiselect({buttonWidth: '180px',maxHeight: 400,dropUp: true,numberDisplayed: 1});
	//Match Flag
	$('#commonMatchFlag').prop('checked',false);
	$("#deliveryChannelDiv").html('');
	$("#deliveryChannel").multiselect("clearSelection");
}

function checkOnlyNumber(val)
{
	var anPattern=/^[0-9]+$/;
	return anPattern.test(val);
}

function Cancel()
{
	document.createProcess.action="displayProcess.rcn";
	document.createProcess.submit(); 
}
	
	
</script>
<div class="container gray-border-bottom">
<ol class="breadcrumb col-lg-11">
    <li class="active"><spring:message code="recon.process.definition.mainMenu"/></li>
	<li class="active"><spring:message code="recon.process.definition.menu"/></li>
	<li><a href="<%=request.getContextPath()%>/displayProcess.rcn"><spring:message code="recon.process.definition.subMenu"/></a></li>
	<li class="active">${MODE}</li>
</ol>
<div class="col-lg-1 text-right">
</div>
</div>
  <form:form name="createProcess" id="createProcess" method="post" autocomplete="off" onsubmit="return false" modelAttribute="processDefinition"> <!-- Modified by Nancy for Mantis Id : 13628 -->
	<div class="container">
		<h4><spring:message code="recon.process.definition.label"/>-${MODE}</h4>
			<input type="hidden" name="mode" id="mode" value="<c:out value="${MODE}"/>">
			
			<c:if test="${MODE eq 'Add' or MODE eq 'Edit'}">
				<div class="must" style="text-align:left">*Mandatory</div>	
			</c:if>	
		<div class="graybox col-lg-12">
<%-- ================================================================== ADD ====================================================================================================== --%>	
		<c:if test="${MODE eq 'Add'}">
			<input type="hidden" name="InchgInd" id="InchgInd" value="<c:out value="${InchgInd}"/>">	
				<div class="col-lg-12">
				<!-- ---------------------------------------------Process Name --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.processName"/><span class="must">*</span></label>
					<div class="col-lg-3">
						<input type="text" class="form-control" id="processName" name="processName" maxlength="20"style="width:180px;"/>
						<div class="must" id="processNameDiv"></div>
					</div>
				
				<!-- --------------------------------------------- Input File Count --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.inputCount"/> <span class="must">*</span></label>
					<div class="col-lg-3">
							<select class="form-control" id="inputCount" name="inputCount" onchange="showFileTypesTemplates();" style="width:180px;">
								<option value="" selected>Not Selected</option>
								<option value="2">2</option>
								<option value="3">3</option>
								<option value="4">4</option>
							</select>
						<div class="must" id="inputCountDiv"></div>
					</div>
				</div>
				
				<div class="col-lg-12">
				<!-- --------------------------------------------- Channel --------------------------------------------------------------------- -->
					<label class="col-lg-3">Channel<span class="must">*</span> </label>
					<div class="col-lg-3">
						<select class="form-control"  id="channel" name="channel" style="width:180px;">
						  <option value="">Not Selected</option>
							<c:forEach items="${ChannelMap}" var="channel">
								<option value="${channel.key}">${channel.value}</option>
							</c:forEach>
						</select>
						<div class="must" id="channelDiv"></div>
					</div>
					
				<!-- --------------------------------------------- Recon Type --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.reconType"/><span class="must">*</span> </label>
					<div class="col-lg-3">
						<select class="form-control"  id="reconType" name="reconType" onchange="clrTemplateValues(this.value);" style="width:180px;">
						  <option value="">Not Selected</option>
						  <c:forEach items="${ReconTypeMap}" var="recon">
								<option value="${recon.key}">${recon.value}</option>
							</c:forEach>
						</select>
						<div class="must" id="reconTypeDiv"></div>
					</div>
				</div>
                 
				<div class="col-lg-12">
				<!-- ---------------------------------------------Retention Period --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.RetentionPeriod"/>(In days)<span class="must">*</span> </label>
					<div class="col-lg-3">
						<input type="text" class="form-control" id="retentionPeriod" name="retentionPeriod" maxlength="3"style="width:180px;"/>
						<div class="must" id="retentionPeriodDiv"></div>
					</div>
					<!-- ---------------------------------------------Retention Volume --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.RetentionVolume"/><span class="must">*</span> </label>
					<div class="col-lg-3">
						<input type="text" class="form-control" id="retentionVolume" name="retentionVolume" maxlength="8" style="width:180px;"/>
						<div class="must" id="retentionVolumeDiv"></div>
					</div>
				</div>
				
				<div class="col-lg-12">
				 	<!-- Added by Mohan Raj.V on 12-07-2016 -->
					<!-- --------------------------------------------- Matching Type --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.matchingType"/><span class="must">*</span> </label>
					<div class="col-lg-3">
						<select class="form-control"  id="matchingType" name="matchingType" style="width:180px;">
						  <option value="">Not Selected</option>
						  <option value="1">One To Many</option>
						  <option value="2">One To One</option>
						</select>
						<div class="must" id="matchingTypeDiv"></div>	
					</div> 
					<!-- -----------------------------------------Delivery Channel Type : Added by dhanapriyanga-------------------------------------------------- -->  
					<label class="col-lg-3"><spring:message code="recon.process.definition.deliveryChannel"/><span class="must">*</span> </label>
					<span class="col-lg-3">
						<select class="form-control" id="deliveryChannel" name="deliveryChannel" style="width:180px;" multiple>
							<c:forEach var="deliveryChannel" items="${DeliveryChannel}">
								<option value="${deliveryChannel.key}">${deliveryChannel.value}</option>
							</c:forEach>
						</select>
					</span>
					<div id="deliveryChannelDiv" class="must"></div>
				</div>	
				
			    <div class="col-lg-12">
			    <!-- --------------------------------------------- Common Matching Flag --------------------------------------------------------------------- -->
			    	<label class="col-lg-3">Identical Matching</label>
					<span class="col-lg-3">
						<input type="checkbox" name="commonMatch" id="commonMatch">
						<input type="hidden" name="commonMatchFlag" id="commonMatchFlag" value="N">
						<span id="identicalMatchingAlert" style="font-weight: bold;color:green;"></span>
					</span>
				</div>
<!-- *************************************************** File Types ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12" id="fileTypesDiv">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">File Types</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">		
				<!-- --------------------------------------------- File Type 1 --------------------------------------------------------------------- -->		
				<div id="f1">
					<label class="col-lg-1" ><spring:message code="recon.process.definition.fileType1"/><span class="must">*</span> </label> 
					<span class="col-lg-2" > 
						<select class="form-control" id="file1" name="file1" onchange="loadTemplateDetails(this.id,'fileType1');" style="width:180px;">
							<option value="">Not Selected</option>
							<c:forEach items="${FileTypesMap}" var="filetype">
								<option value="<c:out value="${filetype.key}"/>"> 
								<c:out value="${filetype.value}"/>
								</option>
					        </c:forEach>
						</select>
						<span class="must" id="file1Div"></span>
					</span>
				</div>
						
		       <!-- --------------------------------------------- File Type 2 --------------------------------------------------------------------- -->	
		       <div id="f2">	
					<label class="col-lg-1"><spring:message code="recon.process.definition.fileType2"/><span class="must">*</span> </label> 
					<span class="col-lg-2"> 
						<select class="form-control" id="file2" name="file2" onchange="loadTemplateDetails(this.id,'fileType2');" style="width:180px;">
						    <option value="">Not Selected</option>
							<c:forEach items="${FileTypesMap}" var="filetype">
								<option value="<c:out value="${filetype.key}"/>"> 
								<c:out value="${filetype.value}"/>
								</option>
				            </c:forEach>
				        </select>
					 <span class="must" id="file2Div"></span>
					</span>
				</div>
						
				<!-- --------------------------------------------- File Type 3 --------------------------------------------------------------------- -->
				<div id="f3">		
					<label class="col-lg-1"><spring:message code="recon.process.definition.fileType3"/><span class="must">*</span></label> 
					<span class="col-lg-2"> 
						<select class="form-control" id="file3" name="file3" onchange="loadTemplateDetails(this.id,'fileType3');" style="width:180px;">
							    <option value="">Not Selected</option>
								<c:forEach items="${FileTypesMap}" var="filetype">
									<option value="<c:out value="${filetype.key}"/>"> 
									<c:out value="${filetype.value}"/>
									</option>
					            </c:forEach>
				         </select>  
					<span class="must" id="file3Div"></span>
					</span>
				</div>
						
				<!-- --------------------------------------------- File Type 4 --------------------------------------------------------------------- -->	
				<div id="f4">	
					<label class="col-lg-1"><spring:message code="recon.process.definition.fileType4"/><span class="must">*</span></label> 
					<span class="col-lg-2"> 
						<select class="form-control"  id="file4" name="file4" onchange="loadTemplateDetails(this.id,'fileType4');" style="width:180px;">
							<option value="">Not Selected</option>
							<c:forEach items="${FileTypesMap}" var="filetype">
								<option value="<c:out value="${filetype.key}"/>"> 
								<c:out value="${filetype.value}"/>
								</option>
				            </c:forEach>
		                </select>  
						<span class="must" id="file4Div"></span>
					</span>
				</div>
			</div>
		</div>		
	</div>				
	
	<!-- *************************************************** Templates ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12" id="templatesDiv">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Templates</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">	
									
				<!-- --------------------------------------------- Template 1 --------------------------------------------------------------------- -->	
				<div id="ft1">
					<label class="col-lg-1"><spring:message code="recon.process.definition.template1"/><span class="must">*</span> </label>
					 <span class="col-lg-2"> 
					 	<select class="form-control" id="fileType1" name="fileType1"  onchange="MasterTemp('file1',this.id,this.value,1);" style="width:180px;">
							<option value="">Not Selected</option>
						</select>
						<span class="must" id="fileType1Div"></span>
					</span>
				</div>
				
				
				<!-- --------------------------------------------- Template 2 --------------------------------------------------------------------- -->	
				<div id="ft2">
					<label class="col-lg-1"><spring:message code="recon.process.definition.template2"/><span class="must">*</span></label> 
					<span class="col-lg-2"> 
						<select class="form-control" id="fileType2" name="fileType2" onchange="MasterTemp('file2',this.id,this.value,2);" style="width:180px;">
							<option value="">Not Selected</option>
						</select>
						<span class="must" id="fileType2Div"></span>
					</span>
				</div>
				
				
				<!-- --------------------------------------------- Template 3 --------------------------------------------------------------------- -->	
				<div id="ft3">
					<label class="col-lg-1"><spring:message code="recon.process.definition.template3"/><span class="must">*</span></label> 
					<span class="col-lg-2"> 
						<select class="form-control" id="fileType3" name="fileType3" onchange="MasterTemp('file3',this.id,this.value,3);" style="width:180px;">
							<option value="">Not Selected</option>
						</select>
						<span class="must" id="fileType3Div"></span>
					</span>
				</div>
				
				
				<!-- --------------------------------------------- Template 4 --------------------------------------------------------------------- -->
				<div id="ft4">
					<label class="col-lg-1" ><spring:message code="recon.process.definition.template4"/><span class="must">*</span></label> 
					<span class="col-lg-2"> 
						<select class="form-control"  id="fileType4" name="fileType4" onchange="MasterTemp('file4',this.id,this.value,4);" style="width:180px;">
							<option value="">Not Selected</option>
						</select>
						<span class="must" id="fileType4Div"></span>
					</span>
			</div>
		</div>
	</div>
  </div>

<!-- *************************************************** Data Tables ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12" id="dataTablesDiv">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Data Tables</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">	
									
				<!-- --------------------------------------------- Data Table 1 --------------------------------------------------------------------- -->	
				<div id="dt1Div">
					<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable1"/></label>
					<label class="col-lg-2" id="fileType1Stage" style="font-weight: bold;color:green;"></label>
					<input type="hidden" value="0" name="fileType1hid" id="fileType1hid">
					
				</div>
				
				<!-- --------------------------------------------- Data Table 2 --------------------------------------------------------------------- -->	
				<div id="dt2Div">
					<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable2"/></label>
					<label class="col-lg-2" id="fileType2Stage" style="font-weight: bold;color:green;"></label>
					<input type="hidden" value="0" name="fileType2hid" id="fileType2hid">
				</div>

				<!-- --------------------------------------------- Data Table 3 --------------------------------------------------------------------- -->	
				<div id="dt3Div">
					<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable3"/></label>
					<label class="col-lg-2" id="fileType3Stage" style="font-weight: bold;color:green;"></label> 
					<input type="hidden" value="0" name="fileType3hid" id="fileType3hid">
				</div>
				
				<!-- --------------------------------------------- Data Table 4 --------------------------------------------------------------------- -->	
				<div id="dt4Div">
					<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable4"/></label>
					<label class="col-lg-2" id="fileType4Stage" style="font-weight: bold;color:green;"></label>
					<input type="hidden" value="0" name="fileType4hid" id="fileType4hid">
				</div>
		</div>
	</div>
  </div>
  
<!-- *************************************************** Matching Fields ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12" id="rankFieldsDiv">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Matching Fields</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">						
				<!-- --------------------------------------------- Rank Field 1 --------------------------------------------------------------------- -->	
					<label class="col-lg-1" >Field 1<span class="must">*</span> </label>
					 <span class="col-lg-2"> 
					 	<select class="form-control" id="rankFields1" name="rankFields1" style="width:180px;" multiple></select>
					 	<span id="rankFields1Div" class="must"></span>
					</span>
					
				<!-- --------------------------------------------- Rank Field 2 --------------------------------------------------------------------- -->	
					<label class="col-lg-1" >Field 2<span class="must">*</span> </label>
					 <span class="col-lg-2"> 
					 	<select class="form-control" id="rankFields2" name="rankFields2" style="width:180px;" multiple></select>
					 	<span id="rankFields2Div" class="must"></span>
					</span>
					
				<!-- --------------------------------------------- Rank Field 3 --------------------------------------------------------------------- -->	
				<div id="rf3Div">
					<label class="col-lg-1" >Field 3<span class="must">*</span> </label>
					 <span class="col-lg-2"> 
					 	<select class="form-control" id="rankFields3" name="rankFields3" style="width:180px;" multiple></select>
					 	<span id="rankFields3Div" class="must"></span>
					</span>
				</div>	
				
				<!-- --------------------------------------------- Rank Field 4 --------------------------------------------------------------------- -->	
				<div id="rf4Div">
					<label class="col-lg-1" >Field 4<span class="must">*</span> </label>
					 <span class="col-lg-2"> 
					 	<select class="form-control" id="rankFields4" name="rankFields4" style="width:180px;" multiple></select>
					 	<span id="rankFields4Div" class="must"></span>
					</span>	
				</div>	
			</div>
		</div>
	</div>		
			
			<!-- --------------------------------------------- Master Template --------------------------------------------------------------------- -->
				<div class="col-lg-12" id="masterDiv"><br>
					<label class="col-lg-2 col-lg-offset-4"><spring:message code="recon.process.definition.masterTemplate"/><span class="must">*</span></label>
					<span class="col-lg-3">
						<select class="form-control" id="masterTemplate" name="masterTemplate" style="width:180px;">
							<option value="">Not Selected</option>
						</select>
						<br><span class="must" id="masterTemplateDiv"></span>
					</span>
			   </div>
			   
      </c:if>
 <%-- ================================================================== EDIT ====================================================================================================== --%>     
      	<c:if test="${MODE eq 'Edit'}">
				<div class="col-lg-12">
					<input type="hidden" name="processId" id="processId" value="${processDefEdit.processId}">
					<input type="hidden" name="inputCount" id="inputCount" value="${processDefEdit.inputCount}">
				<!-- ---------------------------------------------Process Name --------------------------------------------------------------------- -->
				  	<label class="col-lg-3"><spring:message code="recon.process.definition.processName"/></label>
				  		 <span class="col-lg-3"> 
				  		 	<input type="text" class="form-control" value="${processDefEdit.processName}" readonly disabled style="width:180px;"/>
				  		 </span>
				<!-- --------------------------------------------- Input File Count --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.inputCount"/></label>
						<span class="col-lg-3">
				  		 	<select class="form-control" disabled style="width:180px;">
				  		 		<option>${processDefEdit.inputCount}</option>
				  		 	</select>
				  		 </span>
				</div>
			    
				<div class="col-lg-12">
				
				<!-- --------------------------------------------- Channel --------------------------------------------------------------------- -->
					<label class="col-lg-3">Tran Channel</label>
					<div class="col-lg-3">
						<select class="form-control" disabled style="width:180px;">
							<c:forEach items="${ChannelMap}" var="channel">
								<c:if test="${processDefEdit.channel eq channel.key}">
									<option>${channel.value}</option>
								</c:if>
							</c:forEach>
						</select>
					</div>
					
				<!-- --------------------------------------------- Recon Type --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.reconType"/></label>
					<span class="col-lg-3">
						<select class="form-control" disabled style="width:180px;">
							<c:forEach items="${ReconTypeMap}" var="reconType">
								<c:if test="${fn:split(reconType.key,'-')[0] eq processDefEdit.reconType}">
									<option>${reconType.value}</option>
								</c:if>
							</c:forEach>
				  		</select><br>
				  	</span>	
				</div>
				
				<div class="col-lg-12">
				<!-- --------------------------------------------- Retention Period --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.RetentionPeriod"/>(In days)</label>
					<span class="col-lg-3">
						<input type="text" class="form-control" value="${processDefEdit.retentionPeriod}" readonly disabled style="width:180px;"/>
			  		</span>
						
				<!-- ---------------------------------------------Retention Volume --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.RetentionVolume"/> </label>
					<span class="col-lg-3">
						<input type="text" class="form-control" value="${processDefEdit.retentionVolume}" readonly disabled style="width:180px;"/>
			  		 </span>
				</div>
				
				<div class="col-lg-12">
					<!-- --------------------------------------------- Matching Type --------------------------------------------------------------------- -->
						<label class="col-lg-3"><spring:message code="recon.process.definition.matchingType"/></label>
						<span class="col-lg-3">
					  		 <select class="form-control" disabled style="width:180px;">
					  		 	<option>
						  		 	<c:choose>
				    					<c:when test="${processDefEdit.matchingType eq '1'}">
				    						One To Many
				    					</c:when>
				    					<c:otherwise>
				    						One To One
				    					</c:otherwise>
				    				</c:choose>
				    			</option>	
					  		 </select>
					  	</span>
					  	
					  	
					  	<!-- -----------------------------------------Delivery Channel Type : Added by dhanapriyanga-------------------------------------------------- -->  
					<label class="col-lg-3"><spring:message code="recon.process.definition.deliveryChannel"/></label>
					<span class="col-lg-3">
						<select class="form-control" id="deliveryChannel" name="deliveryChannel" style="width:180px;" multiple>
							<c:forEach var="deliveryChannel" items="${DeliveryChannel}">
								<option value="${deliveryChannel.key}" disabled>${deliveryChannel.value}</option>
							</c:forEach>
						</select>
					</span>
				</div>
				
				<div class="col-lg-12">
					<!-- ---------------------------------------------Identical Matching --------------------------------------------------------------------- -->
				 		<label class="col-lg-3">Identical Matching</label>
						<span class="col-lg-3">
							<input type="checkbox" name="commonMatch" id="commonMatch"<c:if test="${processDefEdit.commonMatchFlag eq 'Y'}">checked</c:if>>
							<input type="hidden" name="commonMatchFlag" id="commonMatchFlag" value="${processDefEdit.commonMatchFlag}">
							<span id="identicalMatchingAlert" style="font-weight: bold;color:green;">
								<c:if test="${processDefEdit.commonMatchFlag eq 'Y'}">User has enabled same matching fields!</c:if>
							</span>
						</span>
				</div>
					  	
<!-- *************************************************** File Types ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">File Types</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">		
				<!-- --------------------------------------------- File Type 1 --------------------------------------------------------------------- -->		
					<label class="col-lg-1" ><spring:message code="recon.process.definition.fileType1"/><span class="must">*</span> </label> 
					<span class="col-lg-2" > 
						<select class="form-control" disabled style="width:180px;">
						 	<c:forEach items="${files}" var="Files">
								<c:if test="${processDefEdit.file1 eq Files.key}">
									<option>${Files.value}</option>
								</c:if>
						   </c:forEach>
						 </select>  
					</span>
						
		       <!-- --------------------------------------------- File Type 2 --------------------------------------------------------------------- -->	
		       <label class="col-lg-1"><spring:message code="recon.process.definition.fileType2"/></label>
			     <span class="col-lg-2">
	  		 		<select class="form-control" disabled style="width:180px;">
					 	<c:forEach items="${files}" var="Files">
							<c:if test="${processDefEdit.file2 eq Files.key}">
								<option>${Files.value}</option>
							</c:if>
					   </c:forEach>
					 </select>  
				</span>	
						
				<!-- --------------------------------------------- File Type 3 --------------------------------------------------------------------- -->
				 <c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">
					 <label class="col-lg-1"><spring:message code="recon.process.definition.fileType3"/></label>
					 <span class="col-lg-2">
		  		 		<select class="form-control" disabled style="width:180px;">
						 	<c:forEach items="${files}" var="Files">
								<c:if test="${processDefEdit.file3 eq Files.key}">
									<option>${Files.value}</option>
								</c:if>
						   </c:forEach>
						 </select>  
					</span>	
				 </c:if>
						
				<!-- --------------------------------------------- File Type 4 --------------------------------------------------------------------- -->	
				<c:if test="${processDefEdit.inputCount eq '4'}">
						 <label class="col-lg-1"><spring:message code="recon.process.definition.fileType4"/></label>
						 <span class="col-lg-2">
			  		 		<select class="form-control" disabled style="width:180px;">
							 	<c:forEach items="${files}" var="Files">
									<c:if test="${processDefEdit.file4 eq Files.key}">
										<option>${Files.value}</option>
									</c:if>
							   </c:forEach>
							 </select>  
						</span>	
					 </c:if>
			</div>
		</div>		
	</div>				
	
	<!-- *************************************************** Templates ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Templates</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">	
									
				<!-- --------------------------------------------- Template 1 --------------------------------------------------------------------- -->	
				<label class="col-lg-1"><spring:message code="recon.process.definition.template1"/></label>
			 	<span class="col-lg-2">
	  		 		<select class="form-control" disabled style="width:180px;">
				 		<c:forEach items="${templates1}" var="temp">
							<c:if test="${processDefEdit.fileType1 eq temp.key}">
								<option>${temp.value}</option>
							</c:if>
						</c:forEach>
					</select>
				</span>		
				
				
			 <!-- --------------------------------------------- Template 2 --------------------------------------------------------------------- -->
				 <label class="col-lg-1"><spring:message code="recon.process.definition.template2"/></label>
				  <span class="col-lg-2">
		  		 		<select class="form-control" disabled style="width:180px;">
					 		<c:forEach items="${templates2}" var="temp">
								<c:if test="${processDefEdit.fileType2 eq temp.key}">
									<option>${temp.value}</option>
								</c:if>
							</c:forEach>
						</select>
					</span>	
				<!-- --------------------------------------------- Template 3 --------------------------------------------------------------------- -->	
				<c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">
					 <label class="col-lg-1"><spring:message code="recon.process.definition.template3"/></label>
					 <span class="col-lg-2">
		  		 		<select class="form-control" disabled style="width:180px;">
					 		<c:forEach items="${templates3}" var="temp">
								<c:if test="${processDefEdit.fileType3 eq temp.key}">
									<option>${temp.value}</option>
								</c:if>
							</c:forEach>
						</select>
					 </span>	
				 </c:if>
				 
				 <c:if test="${processDefEdit.inputCount eq '4'}">
				 <!-- --------------------------------------------- Template 4 --------------------------------------------------------------------- -->
					 <label class="col-lg-1"><spring:message code="recon.process.definition.template4"/></label>
					 <span class="col-lg-2">
		  		 		<select class="form-control" disabled style="width:180px;">
					 		<c:forEach items="${templates4}" var="temp">
								<c:if test="${processDefEdit.fileType4 eq temp.key}">
									<option>${temp.value}</option>
								</c:if>
							</c:forEach>
						</select>
					 </span>
				 </c:if>
		</div>
	</div>
  </div>
  
  <!-- *************************************************** Data Tables ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Data Tables</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">	
									
				<!-- --------------------------------------------- Data Table 1 --------------------------------------------------------------------- -->	
				<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable1"/></label>
				<label class="col-lg-2" id="fileType1Stage" style="font-weight: bold;color:green;">${processDefEdit.dataTable1}</label>
					
				
				<!-- --------------------------------------------- Data Table 2 --------------------------------------------------------------------- -->	
				<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable2"/></label>
				<label class="col-lg-2" id="fileType2Stage" style="font-weight: bold;color:green;">${processDefEdit.dataTable2}</label>

				<c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">
					<!-- --------------------------------------------- Data Table 3 --------------------------------------------------------------------- -->	
					<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable3"/></label>
					<label class="col-lg-2" id="fileType3Stage" style="font-weight: bold;color:green;">${processDefEdit.dataTable3}</label> 
				</c:if>	
			
				<c:if test="${ processDefEdit.inputCount eq '4'}">
					<!-- --------------------------------------------- Data Table 4 --------------------------------------------------------------------- -->	
					<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable4"/></label>
					<label class="col-lg-2" id="fileType4Stage" style="font-weight: bold;color:green;">${processDefEdit.dataTable4}</label>
				</c:if>		
		</div>
	</div>
  </div>

<!-- *************************************************** Matching Fields ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Matching Fields</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">						
				<!-- --------------------------------------------- Rank Field 1 --------------------------------------------------------------------- -->	
					<label class="col-lg-1" >Field 1<span class="must">*</span> </label>
					 <span class="col-lg-2"> 
					 	<select class="form-control" id="rankFields1" name="rankFields1" style="width:180px;" multiple></select>
					 	<span id="rankFields1Div" class="must"></span>
					</span>
					
				<!-- --------------------------------------------- Rank Field 2 --------------------------------------------------------------------- -->	
					<label class="col-lg-1" >Field 2<span class="must">*</span> </label>
					 <span class="col-lg-2"> 
					 	<select class="form-control" id="rankFields2" name="rankFields2" style="width:180px;" multiple></select>
					 	<span id="rankFields2Div" class="must"></span>
					</span>
					
				<!-- --------------------------------------------- Field 3 --------------------------------------------------------------------- -->	
				<c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">
					 <label class="col-lg-1">Field 3<span class="must">*</span></label>
				 		<span class="col-lg-2">
					 		<select class="form-control" id="rankFields3" name="rankFields3" style="width:180px;" multiple ></select>
					 		<span id="rankFields3Div" class="must"></span>
					 	</span>	
				 </c:if>
					 
				<!-- --------------------------------------------- Field 4 --------------------------------------------------------------------- -->	 
				 <c:if test="${processDefEdit.inputCount eq '4'}">
					 <label class="col-lg-1">Field 4<span class="must">*</span></label>
				 		<span class="col-lg-2">
					 		<select class="form-control" id="rankFields4" name="rankFields4" style="width:180px;" multiple ></select>
					 	</span>	
					 	<span id="rankFields4Div" class="must"></span>
				 </c:if>
			</div>
		</div>
	</div>				
				
				
				<!-- --------------------------------------------- Master Template --------------------------------------------------------------------- -->	
				<c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">		
					<div class="col-lg-12"><br>
						<label class="col-lg-2 col-lg-offset-4"><spring:message code="recon.process.definition.masterTemplate"/></label>
						<span class="col-lg-3">
							<select class="form-control" disabled style="width:180px;">	
								<option>${processDefEdit.masterTemplate}</option>
							</select>
						</span>		
					</div>		
				</c:if> 		
	</c:if>
		
 <%-- ================================================================== VIEW ====================================================================================================== --%>
				
	<c:if test="${MODE eq 'View'}">
				<div class="col-lg-12">
				<!-- ---------------------------------------------Process Name --------------------------------------------------------------------- -->
				  	<label class="col-lg-3"><spring:message code="recon.process.definition.processName"/></label>
				  		 <label class="col-lg-3 gray-txt">${processDefEdit.processName}</label>
				<!-- --------------------------------------------- Input File Count --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.inputCount"/></label>
						 <label class="col-lg-3 gray-txt">${processDefEdit.inputCount}</label>
				</div>
			    
				<div class="col-lg-12">
				<!-- --------------------------------------------- Channel --------------------------------------------------------------------- -->
					<label class="col-lg-3">Tran Channel</label>
					<div class="col-lg-3">
							<c:forEach items="${ChannelMap}" var="channel">
								<c:if test="${processDefEdit.channel eq channel.key}">
									<label class="gray-txt">${channel.value}</label>
								</c:if>
							</c:forEach>
					</div>
				<!-- --------------------------------------------- Recon Type --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.reconType"/></label>
						<span class="col-lg-3 ">
							<c:forEach items="${ReconTypeMap}" var="reconType">
								<c:if test="${fn:split(reconType.key,'-')[0] eq processDefEdit.reconType}">
									<label class="gray-txt">${reconType.value}</label>
								</c:if>
							</c:forEach>
						</span>	
				</div>
				
				<div class="col-lg-12">
				<!-- --------------------------------------------- Retention Period --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.RetentionPeriod"/>(In days)</label>
					<label class="col-lg-3 gray-txt">${processDefEdit.retentionPeriod}</label>
						
				<!-- ---------------------------------------------Retention Volume --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.RetentionVolume"/> </label>
					<label class="col-lg-3 gray-txt">${processDefEdit.retentionVolume}</label>		
				</div>
				
				<div class="col-lg-12">
					<!-- --------------------------------------------- Matching Type --------------------------------------------------------------------- -->
					<label class="col-lg-3"><spring:message code="recon.process.definition.matchingType"/></label>
						<label class="col-lg-3 gray-txt">
							<c:if test="${processDefEdit.matchingType == '1'}">One To Many</c:if>
							<c:if test="${processDefEdit.matchingType == '2'}">One To One</c:if>
					</label>
					
					
						<!-- -----------------------------------------Delivery Channel Type : Added by dhanapriyanga-------------------------------------------------- -->  
					<label class="col-lg-3"><spring:message code="recon.process.definition.deliveryChannel"/></label>
					<span class="col-lg-3">
						<select class="form-control" id="deliveryChannel" name="deliveryChannel" style="width:180px;" multiple>
							<c:forEach var="deliveryChannel" items="${DeliveryChannel}">
								<option value="${deliveryChannel.key}" disabled>${deliveryChannel.value}</option>
							</c:forEach>
						</select>
					</span>
				</div>	
				<div class="col-lg-12">
				<!-- --------------------------------------------- Identical Matching --------------------------------------------------------------------- -->
				 	<label class="col-lg-3">Identical Matching</label>
					<span class="col-lg-3">
						<input type="checkbox" disabled <c:if test="${processDefEdit.commonMatchFlag eq 'Y'}">checked</c:if>>
						<c:if test="${processDefEdit.commonMatchFlag eq 'Y'}">
							<span style="font-weight: bold;color:green;">User has enabled same matching fields!</span>
						</c:if>
					</span>
				</div>
				
	<!-- *************************************************** File Types ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">File Types</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">
					<!-- --------------------------------------------- File Type 1 --------------------------------------------------------------------- -->
						 <label class="col-lg-1"><spring:message code="recon.process.definition.fileType1"/></label>
						 	<c:forEach items="${files}" var="Files">
								<c:if test="${processDefEdit.file1 eq Files.key}">
									<label class="col-lg-2 gray-txt">${Files.value}</label>
								</c:if>
						   </c:forEach>
					 
					 <!-- --------------------------------------------- File Type 2 --------------------------------------------------------------------- -->
					     <label class="col-lg-1"><spring:message code="recon.process.definition.fileType2"/></label>
							<c:forEach items="${files}" var="Files">
								<c:if test="${processDefEdit.file2 eq Files.key}">
									<label class="col-lg-2 gray-txt">${Files.value}</label>
								</c:if>
						   </c:forEach>
					 
					 <!-- --------------------------------------------- File Type 3 --------------------------------------------------------------------- -->
					 <c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">
						 <label class="col-lg-1"><spring:message code="recon.process.definition.fileType3"/></label>
							<c:forEach items="${files}" var="Files">
								<c:if test="${processDefEdit.file3 eq Files.key}">
									<label class="col-lg-2 gray-txt">${Files.value}</label>
								</c:if>
						   </c:forEach>
					 </c:if>
					 
					 <!-- --------------------------------------------- File Type 4 --------------------------------------------------------------------- -->
					 <c:if test="${processDefEdit.inputCount eq '4'}">
						 <label class="col-lg-1"><spring:message code="recon.process.definition.fileType4"/></label>
							<c:forEach items="${files}" var="Files">
								<c:if test="${processDefEdit.file4 eq Files.key}">
									<label class="col-lg-2 gray-txt">${Files.value}</label>
								</c:if>
						   </c:forEach>
					 </c:if>
				 </div>
			</div>
		</div>				 


<!-- *************************************************** Templates ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Templates</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">	
					 <!-- --------------------------------------------- Template 1 --------------------------------------------------------------------- -->
					 	<label class="col-lg-1"><spring:message code="recon.process.definition.template2"/></label>
					 		<span class="col-lg-2">
						 		<c:forEach items="${templates1}" var="temp">
									<c:if test="${processDefEdit.fileType1 eq temp.key}">
										<label class="gray-txt">${temp.value}</label>
									</c:if>
								</c:forEach>
							</span>	
								
					 <!-- --------------------------------------------- Template 2 --------------------------------------------------------------------- -->
					 <label class="col-lg-1"><spring:message code="recon.process.definition.template2"/></label>
					 	<span class="col-lg-2">
							<c:forEach items="${templates2}" var="temp">
								<c:if test="${processDefEdit.fileType2 eq temp.key}">
									<label class="gray-txt">${temp.value}</label>
								</c:if>
							</c:forEach>
						</span>	
							
					 
					<c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">
					<!-- --------------------------------------------- Template 3 --------------------------------------------------------------------- -->
						 <label class="col-lg-1"><spring:message code="recon.process.definition.template3"/></label>
						 	<span class="col-lg-2">
								<c:forEach items="${templates3}" var="temp">
									<c:if test="${processDefEdit.fileType3 eq temp.key}">
										<label class="gray-txt">${temp.value}</label>
									</c:if>
								</c:forEach>
						  </span>	
					 </c:if>
					 
					 <c:if test="${processDefEdit.inputCount eq '4'}">
					 <!-- --------------------------------------------- Template 4 --------------------------------------------------------------------- -->
						 <label class="col-lg-1"><spring:message code="recon.process.definition.template4"/></label>
						 	<span class="col-lg-2">
								<c:forEach items="${templates4}" var="temp">
									<c:if test="${processDefEdit.fileType4 eq temp.key}">
										<label class="gray-txt">${temp.value}</label>
									</c:if>
								</c:forEach>
						  </span>		
					 </c:if>
				</div>	
			</div>
	</div>			
				
<!-- *************************************************** Data Tables ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Data Tables</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">	
									
				<!-- --------------------------------------------- Data Table 1 --------------------------------------------------------------------- -->	
				<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable1"/></label>
				<label class="col-lg-2" id="fileType1Stage" style="font-weight: bold;color:green;">${processDefEdit.dataTable1}</label>
					
				
				<!-- --------------------------------------------- Data Table 2 --------------------------------------------------------------------- -->	
				<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable2"/></label>
				<label class="col-lg-2" id="fileType2Stage" style="font-weight: bold;color:green;">${processDefEdit.dataTable2}</label>

				<c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">
					<!-- --------------------------------------------- Data Table 3 --------------------------------------------------------------------- -->	
					<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable3"/></label>
					<label class="col-lg-2" id="fileType3Stage" style="font-weight: bold;color:green;">${processDefEdit.dataTable3}</label> 
				</c:if>	
			
				<c:if test="${processDefEdit.inputCount eq '4'}">
					<!-- --------------------------------------------- Data Table 4 --------------------------------------------------------------------- -->	
					<label class="col-lg-1"><spring:message code="recon.process.definition.dataTable4"/></label>
					<label class="col-lg-2" id="fileType4Stage" style="font-weight: bold;color:green;">${processDefEdit.dataTable4}</label>
				</c:if>	
		</div>
	</div>
  </div>				
<!-- *************************************************** Matching Fields ************************************************************************************** -->	
	<div class="panel panel-default col-lg-12">
		<div class="panel-heading" role="tab" ><h4 class="panel-title" style="font-weight: bolder;">Matching Fields</h4></div>
			<div class="panel-collapse collapse in" role="tabpanel" >
				<div class="panel-body">					
					 <!-- --------------------------------------------- Field 1 --------------------------------------------------------------------- -->
					 	<label class="col-lg-1">Field 1</label>
					 		<c:set var="rankField1Split" value="${fn:split(processDefEdit.rankFields1,',')}"/>
					 		<span class="col-lg-2" id="rankField1Span">
						 		<select class="form-control" id="rankFields1" style="width:180px;" multiple >
						 			<c:forEach items="${rankField1Split}" var="fields">
						 				<option selected disabled>${fields}</option>
						 			</c:forEach>
						 		</select>
						 	</span>	
								
					 <!-- --------------------------------------------- Field 2 --------------------------------------------------------------------- -->
						 <label class="col-lg-1">Field 2</label>
							<c:set var="rankField2Split" value="${fn:split(processDefEdit.rankFields2,',')}"/>
					 		<span class="col-lg-2" id="rankField2Span">
						 		<select class="form-control" id="rankFields2" style="width:180px;" multiple >
						 			<c:forEach items="${rankField2Split}" var="fields">
						 				<option selected disabled>${fields}</option>
						 			</c:forEach>
						 		</select>
						 	</span>		
					 
					<c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">
					<!-- --------------------------------------------- Field 3 --------------------------------------------------------------------- -->
						 <label class="col-lg-1">Field 3</label>
							<c:set var="rankField3Split" value="${fn:split(processDefEdit.rankFields3,',')}"/>
					 		<span class="col-lg-2" id="rankField3Span">
						 		<select class="form-control" id="rankFields3" style="width:180px;" multiple >
						 			<c:forEach items="${rankField3Split}" var="fields">
						 				<option selected disabled>${fields}</option>
						 			</c:forEach>
						 		</select>
						 	</span>	
					 </c:if>
					 
					 <c:if test="${processDefEdit.inputCount eq '4'}">
					 <!-- --------------------------------------------- Field 4 --------------------------------------------------------------------- -->
						 <label class="col-lg-1">Field 4</label>
							<c:set var="rankField4Split" value="${fn:split(processDefEdit.rankFields4,',')}"/>
					 		<span class="col-lg-2" id="rankField4Span">
						 		<select class="form-control" id="rankFields4" style="width:180px;" multiple >
						 			<c:forEach items="${rankField4Split}" var="fields">
						 				<option selected disabled>${fields}</option>
						 			</c:forEach>
						 		</select>
						 	</span>	
					 </c:if>
				</div>
			</div>
		</div>		
				
				
			<!-- ---------------------------------------------Master Template --------------------------------------------------------------------- -->
			<c:if test="${processDefEdit.inputCount eq '3' or processDefEdit.inputCount eq '4'}">		
				<div class="col-lg-12"><br>
					<label class="col-lg-2 col-lg-offset-4"><spring:message code="recon.process.definition.masterTemplate"/></label>
						<label class="col-lg-3 gray-txt">${processDefEdit.masterTemplate}</label>
				</div>		
			</c:if> 
	</c:if>

	<!-- ----------------------------------------------------------Buttons ------------------------------------------------------------------- -->
			<div class="col-lg-12" align="center"><br>
				<c:if test="${MODE eq 'Add'}">
					<input type="button" id="submitButton" value="<spring:message code="recon.process.definition.submit.button"/>" class="btn btn-primary" onClick="AddEdit();"></input>&nbsp;&nbsp;&nbsp;
					<input type="button" value="<spring:message code="recon.process.definition.reset.button"/>" class="btn btn-primary gray-btn" onClick="ResetProcess();" />&nbsp;&nbsp;&nbsp;
				</c:if>	
				
				<c:if test="${MODE eq 'Edit'}">
					<input type="button" value="<spring:message code="recon.process.definition.save.button"/>" class="btn btn-primary" onClick="AddEdit();"/>&nbsp;&nbsp;&nbsp;
				</c:if>	
				
				 <input type="button" value="<spring:message code="recon.process.definition.cancel.button"/>" class="btn btn-primary gray-btn" onClick="return Cancel();"/>
		    </div>
		</div>		
	</div>
</form:form>
