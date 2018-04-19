/**
 * 
 */
package com.fss.recon.core.daoimpl;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.fss.recon.core.dao.ReconciliationProcessDao;
import com.fss.recon.core.exception.ReconUserDefinedException;
import com.fss.recon.core.model.ProcessDefinitionDetails;
import com.fss.recon.core.util.LoopBack;
import com.fss.recon.core.util.QueryPropertyUtil;
import com.fss.recon.core.util.ReconConstants;
import com.fss.recon.jdbcConn.utils.DatabaseService;
import com.fss.recon.jdbcConn.utils.LocalObject;

/**
 * @author Ishwarya
 *
 */
@Repository
public class ReconciliationProcessDaoImpl implements ReconciliationProcessDao {

	private static final Logger logger = Logger.getLogger(ReconciliationProcessDaoImpl.class);
	 @Autowired
	 private DataSource dataSource;
	// Map<Object, Object> map = null;
	 DatabaseService dbService = null;
	@Override
	public boolean insertProcessStatus(String processId,String processName,String processStatus,String processType,String institutionName,String userKey,String instCode)
			throws Exception {
		
		    logger.debug("Reconciliation insertProcessStatus start");
			String query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.INSERT.STATUS");
			boolean insertStatus = false;
			LocalObject localObject = null;
	        DatabaseService databaseService=null;
	        Connection connection=null;
			try
			{
				databaseService = new DatabaseService();
	        	localObject = new LocalObject(); 
				localObject.put(1, processId); 
				localObject.put(2, processType); 
				localObject.put(3, processName); 
				localObject.put(4, processStatus);
				localObject.put(5, "R");//Report Status -> Running 
				localObject.put(6, instCode);
				localObject.put(7, userKey);
				
				//Modified By Kaviraj on 05-05-2016
				connection=databaseService.getDBConnectionWithInstitutionName(institutionName);
				int count = databaseService.executeUpdate(query,localObject,connection);
	        	if (count > 0) 
				{
					localObject = null;
					insertStatus = true;
				}
	        }catch(Exception e){
	           
	        	logger.debug("Reconciliation insertProcessStatus"+e.getMessage());
	        }finally
	        {
	    		localObject=null;
	    		databaseService = null;
	    		if(connection!=null)
	    			connection.close();
	        }

	        logger.debug("Reconciliation insertProcessStatus End"+query);
			return insertStatus;
		
	}

	@Override
	public void updateProcessStatus(String processId,String updateProcessStatus,String processType) throws Exception {
		
		logger.debug("Reconciliation updateProcessStatus start");
		
		String query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.UPDATE.STATUS");
		LocalObject localObject = null;
        DatabaseService databaseService=null;
       
		try
		{
			
			databaseService = new DatabaseService();
        	localObject = new LocalObject(); 
			
			localObject.put(1, updateProcessStatus); 
			localObject.put(2, processId); 
			localObject.put(3, processType); 
			localObject.put(4, ReconConstants.PROCESS_TYPE_RECONCILIATION); 
			  	
        	
			int count = databaseService.executeUpdate(query,localObject);

        	if (count > 0) 
			{
				
				localObject = null;				
				
			}
	         
        	
        }catch(Exception e){
           
        	 logger.error("Reconciliation updateProcessStatus "+e.getMessage());
        }finally
        {

    		localObject=null;
    		databaseService = null;
        }

			 logger.debug("Reconciliation updateProcessStatus End"+query);
			}

	@Override
	public String getProcessName(String processId,String institutionName) throws Exception {
		
		logger.debug("Reconciliation getProcessName starts..");
		String query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.RETRIEVE_PROCESS_NAME");
		logger.debug("Query to get getProcessName:"+query);
		LocalObject localObject = null;
        DatabaseService databaseService=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
        String processName = null;
        Connection connection=null;
		try
		{
			databaseService = new DatabaseService();
        	localObject = new LocalObject();
        	localObject.put(1, processId);
        	 
        	//Modified By Kaviraj on 05-05-2016
			connection=databaseService.getDBConnectionWithInstitutionName(institutionName);
        	objList=databaseService.executeQuery(query, localObject,connection);
        	itr = objList.iterator();
        	while (itr.hasNext()) 
			{
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;
				processName = map.get("RPM_PROCESS_NAME").toString();
			}
        	logger.info("Reconciliation getProcessName Ends..");
		}
		catch(Exception e)
		{
			logger.debug("Exception Occurred during getProcessName"+e);
	    }finally
        {
        	map = null;
    		objList = null;
    		localObject=null;
    		databaseService = null;
    		if(connection!=null)
    			connection.close();
        }

        logger.debug("Reconciliation getProcessName End"+query);
		return processName;
		
	}

	@Override
	public String callMatchProcedure(String processId,String userId,String institutionName) throws Exception {
		
		logger.debug("Reconciliation callMatchProcedure start");
		
		CallableStatement callableStatement = null;
		String procedure =  QueryPropertyUtil.getProperty("DB.RECONCILIATION..callMatchProcedure");
		DatabaseService databaseService=null;
		String message = "";
		Connection connection=null;
		try{
			databaseService = new DatabaseService();
			//Modified By Kaviraj on 05-05-2016
			connection=databaseService.getDBConnectionWithInstitutionName(institutionName);
			callableStatement = connection.prepareCall(procedure);
			 
			callableStatement.setString(1, processId);
			callableStatement.registerOutParameter(2, java.sql.Types.VARCHAR);
									
			callableStatement.executeUpdate();
			message = callableStatement.getString(2);
			logger.debug("Reconciliation Procedure Message is :"+message);
		}
		catch(Exception e)
		{
     	   logger.error("Reconciliation callMatchProcedure "+e.getMessage());
	    }finally
	    {	      
	    	if(connection!=null)
	    		connection.close();
	     }
 		logger.debug("Reconciliation callMatchProcedure End"+"SP_RECON_PROCESS");
		return message;
	}

	@Override
	public ProcessDefinitionDetails getProcessDetails(String processId, String processType) throws Exception {
		
		logger.debug("Reconciliation getProcessDetails start");
		String query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.RETRIEVE_PROCESS_DETAILS_LIST");
		LocalObject localObject = null;
        DatabaseService databaseService=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
    	ProcessDefinitionDetails processDefinitionDetails = new ProcessDefinitionDetails();	
       
		try
		{
			databaseService = new DatabaseService();
        	localObject = new LocalObject();
        	localObject.put(1, processId);

        	objList=databaseService.executeQuery(query, localObject);
        	itr = objList.iterator();
        	while (itr.hasNext()) 
			{
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;

				processDefinitionDetails.setOutputFileLocation(map.get("RPD_OUTPUT_FILE_LOC").toString());
				processDefinitionDetails.setOutputFilePath(map.get("RPD_OUTPUT_FILE_PATH").toString());
					
			}		
			
		}
		catch(Exception e){
	           
     	   logger.error("Reconciliation getProcessDetails "+e.getMessage());
	        }finally
	        {
	        	map = null;
	    		objList = null;
	    		localObject=null;
	    		databaseService = null;
	        }
		
	        logger.debug("Reconciliation getProcessDetails End"+query);
		return processDefinitionDetails;
	}

	@Override
	public Map<String, Object> callMatchProcedureDump(String processId) throws Exception {
		
		logger.debug("Reconciliation callMatchProcedureDump start");
		
		SimpleJdbcCall jdbcCall = new SimpleJdbcCall(this.dataSource);
 		SqlParameterSource in = new MapSqlParameterSource()
 		.addValue("PRM_PROCESS_ID", processId);
 		Map<String, Object> out1 = jdbcCall.withProcedureName("SP_RECON_PROCESS_DUMP").execute(in);
 		 logger.debug("Reconciliation callMatchProcedureDump End"+"SP_RECON_PROCESS_DUMP");
		return out1;
		
	}

	

	@Override
	public boolean updateStatusInBatch(String processId,String procedureStatus,String reportStatus,String errorDesc, String institutionName) throws Exception 
	{
       logger.debug("Reconciliation updateReportProcessStatus start");
		String query="";
		boolean updateReportProcessStatus = false;
		LocalObject localObject = null;
        DatabaseService databaseService=null;
        Connection connection=null;
		try
		{
			
			databaseService = new DatabaseService();
        	localObject = new LocalObject(); 
			
			if(procedureStatus!=null && reportStatus!=null)
			{
				query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.UPDATE.RECON_AND_REPORT.STATUS");
				localObject.put(1, procedureStatus);
				localObject.put(2, reportStatus);
				localObject.put(3, processId); 
			}else if(procedureStatus!=null)
			{
				query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.UPDATE.RECON.STATUS");
				localObject.put(1, procedureStatus);
				localObject.put(2, processId);
			}else if(reportStatus!=null)
			{
				query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.UPDATE.REPORT.STATUS");
				localObject.put(1, reportStatus);
				localObject.put(2, processId);
			}else if(errorDesc != null){
				query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.UPDATE.ERROR_DESC");
				localObject.put(1, errorDesc);
				localObject.put(2, processId);
			}
        	
			//Modified By Kaviraj on 05-05-2016
			connection=databaseService.getDBConnectionWithInstitutionName(institutionName);
			int count = databaseService.executeUpdate(query,localObject,connection);
        	if (count > 0) 
			{
				localObject = null;
				updateReportProcessStatus = true;
			}
        }catch(Exception e){
           
			logger.error("Reconciliation updateReportProcessStatus"+ e);
        }finally
        {
        	if(connection!=null)
        		connection.close();
    		localObject=null;
    		databaseService = null;
        }

        logger.debug("Reconciliation updateReportProcessStatus End"+query);
		return updateReportProcessStatus;

	}

	// Added by Mohan Raj.V for parallel processing of Reconciliation on 14-12-16
	@Override
	public int callOne2OneReconProcedure(String dynColumn, String query,
			String tabName1, String tabName2, LoopBack loopBack) throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		int  status = 0;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("Recon Procedure Start for DT :"+tabName1); // Added by Mohan Raj.V to log Time

			connection = new DatabaseService().getConnection(loopBack);

				String firstProcedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callReconProcedure");
				
				callableStatement = connection.prepareCall(firstProcedureCall);
				logger.debug("calling the  SP_RECON_PROCESS_BENCH Procedure : " + firstProcedureCall);

				callableStatement.setString(1, dynColumn);
				callableStatement.setString(2, query);
				callableStatement.setString(3, tabName1);
				callableStatement.setString(4, tabName2);
				
				callableStatement.registerOutParameter(5, java.sql.Types.VARCHAR);
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(5);
				logger.debug("SP_RECON_PROCESS procedure  executed status : " + responseMsg);
				logger.info("SP_RECON_PROCESS arguments  call SP_RECON_PROCESS_BENCH("+dynColumn+", "+query+", "+tabName1+", "+tabName2+")");
				logger.info("SP_RECON_PROCESS Executed Status for DT  :"+tabName1+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("SP_RECON_PROCESS arguments  call SP_RECON_PROCESS_BENCH("+dynColumn+", "+query+", "+tabName1+", "+tabName2+")");
					logger.error("SP_RECON_PROCESS Executed Status for DT  :"+tabName1+" = "+responseMsg);
				}
				
				if (responseMsg != null && responseMsg.equals("OK"))
					status = 1;

				Long endTime = System.currentTimeMillis();
			logger.info("Extraction SP_RECON_PROCESS_BENCH End for DT :"+tabName1); 
			logger.info("Time Taken by SP_RECON_PROCESS_BENCH for DT :"+tabName1+" = "+(endTime - startTime)/1000);

		} catch (Exception e) {
			logger.error("Exception occured in SP_RECON_PROCESS_BENCH() : " + e);
			throw new ReconUserDefinedException("Exception occured in SP_RECON_PROCESS_BENCH :"+e); //SP_ONE2ONE_RECON_BENCH
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}

	@Override
	public Map<Integer, List<String>> fetchReconMap(String processId, LoopBack loopBack)
			throws Exception {
		
		LocalObject localObject = null;
        DatabaseService databaseService=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
    	Map<Integer, List<String>> reconMap = new HashMap<Integer, List<String>>();

    	List<String> list1 = new ArrayList<String>();
    	List<String> list2 = new ArrayList<String>();
    	List<String> list3 = new ArrayList<String>();
    	List<String> list4 = new ArrayList<String>();
    	List<String> list5 = new ArrayList<String>();
    	List<String> list6 = new ArrayList<String>();
    	List<String> list7 = new ArrayList<String>();
    	List<String> list8 = new ArrayList<String>();
    	List<String> list9 = new ArrayList<String>();
    	List<String> list10 = new ArrayList<String>();
    	List<String> list11 = new ArrayList<String>();
    	List<String> list12 = new ArrayList<String>();
    	String dynFlag1 = "";  
		String tab1 =  "";		
		String dynFlag2 =  "";	
		String tab2 =  "";		
		String dynFlag3 =  "";	
		String tab3 =  "";		
		String dynFlag4 =  "";	
		String tab4 =  "";		
		String query1 = "";
		String query2 = "";
		String query3 = "";
		String query4 = "";
		String query5 = "";
		String query6 = "";
		String inputCount = "";
		String [] matchingField = null;
//		String [] matchingField2 = null;
//		String [] matchingField3 = null;
//		String [] matchingField4 = null;
		String fieldA_B = "",fieldB_A = "", fieldB_C = "",fieldC_B = "", fieldC_A = "", fieldA_C = "", fieldC_D = "", fieldD_C = "",fieldD_A = "",fieldA_D = "",
				fieldB_D = "", fieldD_B = "";

       
		try
		{
			logger.info("Entered into fetchReconMap details ");
			
			String query = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.fetchReconMap");

			logger.debug("Query to FetchReconMap Details : "+query);

			databaseService = new DatabaseService();
        	localObject = new LocalObject();
        	if (loopBack != null) {
				localObject.put("LOOPBACK", loopBack);
			}
        	localObject.put(1, processId);
        	

        	objList=databaseService.executeQuery(query, localObject);
        	itr = objList.iterator();
        	while (itr.hasNext()) 
			{
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;

				inputCount =  map.get("INPUTCOUNT").toString() ;
				
				 dynFlag1 = map.get("DYNFLAG1").toString();
				 tab1 = map.get("TAB1").toString();
				 dynFlag2 = map.get("DYNFLAG2").toString();
				 tab2 = map.get("TAB2").toString();
				 dynFlag3 = map.get("DYNFLAG3").toString();
				 tab3 = map.get("TAB3").toString();
				 dynFlag4 = map.get("DYNFLAG4").toString();
				 tab4 = map.get("TAB4").toString();
				 
				 switch(map.get("INFO1").toString()){
					 case "A-B":
						query1 = map.get("QUERY").toString();
						matchingField = map.get("MATCHINGFIELDS").toString().split("\\|");
						fieldA_B = matchingField[0];
						fieldB_A = matchingField[1];
						break;
					 case "B-C":
						query2 = map.get("QUERY").toString();
						matchingField = map.get("MATCHINGFIELDS").toString().split("\\|");
						fieldB_C = matchingField[0];
						fieldC_B = matchingField[1];
						break;
					 case "C-A":
						query3 = map.get("QUERY").toString();
						matchingField = map.get("MATCHINGFIELDS").toString().split("\\|");
						fieldC_A = matchingField[0];
						fieldA_C = matchingField[1];
						break;
					 case "C-D":
						query3 = map.get("QUERY").toString();
						matchingField = map.get("MATCHINGFIELDS").toString().split("\\|");
						fieldC_D = matchingField[0];
						fieldD_C = matchingField[1];
						break;
					 case "D-A":
						query4 = map.get("QUERY").toString();
						matchingField = map.get("MATCHINGFIELDS").toString().split("\\|");
						fieldD_A = matchingField[0];
						fieldA_D = matchingField[1];
						break;
					 case "A-C":
						query5 = map.get("QUERY").toString();
						matchingField = map.get("MATCHINGFIELDS").toString().split("\\|");
						fieldA_C = matchingField[0];
						fieldC_A = matchingField[1];
						break;
					 case "B-D":
						query6 = map.get("QUERY").toString();
						matchingField = map.get("MATCHINGFIELDS").toString().split("\\|");
						fieldB_D = matchingField[0];
						fieldD_B = matchingField[1];
						break;
					 default :
						 break;
				 }
			}
        	
        	int count = Integer.parseInt(inputCount);
        	if( count == 2 ){
        		
        		String frameQueryList [] = query1.toUpperCase().split("MINUS");
        		String queryB_A = frameQueryList[1].trim()+" MINUS "+frameQueryList[0].trim(); 
        		// A-B 
        		list1.add(dynFlag2);
        		list1.add(query1);
        		list1.add(tab1);
        		list1.add(tab2);
        		list1.add(fieldA_B);
        		//B-A
        		list2.add(dynFlag1);
        		list2.add(queryB_A);
        		list2.add(tab2);
        		list2.add(tab1);
        		list2.add(fieldB_A);
        		reconMap.put(1, list1);
        		reconMap.put(2, list2);
        		
        	} else if( count == 3 ) {
        		
        		String frameQueryList1 [] = query1.split("MINUS");
        		String queryB_A = frameQueryList1[1].trim()+" MINUS "+frameQueryList1[0].trim();
        		
        		String frameQueryList2 [] = query2.split("MINUS");
        		String queryC_B = frameQueryList2[1].trim()+" MINUS "+frameQueryList2[0].trim();
        		
        		String frameQueryList3 [] = query3.split("MINUS");
        		String queryA_C = frameQueryList3[1].trim()+" MINUS "+frameQueryList3[0].trim();
        		
        		// A-B
        		
        		list1.add(dynFlag2);
        		list1.add(query1);
        		list1.add(tab1);
        		list1.add(tab2);
        		list1.add(fieldA_B);
        		
        		// B-C 
        		list2.add(dynFlag3);
        		list2.add(query2);
        		list2.add(tab2);
        		list2.add(tab3);
        		list2.add(fieldB_C);
        		
        		//C-A
        		list3.add(dynFlag1);
        		list3.add(query3);
        		list3.add(tab3);
        		list3.add(tab1);
        		list3.add(fieldC_A);
        		
        		//B-A
        		list4.add(dynFlag1);
        		list4.add(queryB_A);
        		list4.add(tab2);
        		list4.add(tab1);
        		list4.add(fieldB_A);
        		
        		// C-B 
        		list5.add(dynFlag2);
        		list5.add(queryC_B);
        		list5.add(tab3);
        		list5.add(tab2);
        		list5.add(fieldC_B);
        		
        		//A-C
        		list6.add(dynFlag3);
        		list6.add(queryA_C);
        		list6.add(tab1);
        		list6.add(tab3);
        		list6.add(fieldA_C);
        		
        		reconMap.put(1, list1);
        		reconMap.put(2, list2);
        		reconMap.put(3, list3);
        		reconMap.put(4, list4);
        		reconMap.put(5, list5);
        		reconMap.put(6, list6);
        		
        	} else if ( count == 4 ) {
        		//A-B,B-C,C-D,D-A
        		//A-B B-A, C-D D-C, A-C C-A ,B-D D-B, A-D D-A ,B-C C-B
// 			4 Way we need to fine tune --modifications required for 4 way 
        		String frameQueryList1 [] = query1.toUpperCase().split("MINUS");
        		String queryB_A = frameQueryList1[1].trim()+" MINUS "+frameQueryList1[0].trim();
        		
        		String frameQueryList2 [] = query2.toUpperCase().split("MINUS");
        		String queryC_B = frameQueryList2[1].trim()+" MINUS "+frameQueryList2[0].trim();
        		
        		String frameQueryList3 [] = query3.toUpperCase().split("MINUS");
        		String queryD_C = frameQueryList3[1].trim()+" MINUS "+frameQueryList3[0].trim();
        		
        		String frameQueryList4 [] = query4.toUpperCase().split("MINUS");
        		String queryA_D = frameQueryList4[1].trim()+" MINUS "+frameQueryList4[0].trim();
        		
        		String frameQueryList5 [] = query5.toUpperCase().split("MINUS");
        		String queryC_A = frameQueryList5[1].trim()+" MINUS "+frameQueryList5[0].trim();
        		
        		String frameQueryList6 [] = query6.toUpperCase().split("MINUS");
        		String queryD_B =frameQueryList6[1].trim()+" MINUS "+frameQueryList6[0].trim();
        		
        		// A-B
        		list1.add(dynFlag2);
        		list1.add(query1);
        		list1.add(tab1);
        		list1.add(tab2);
        		list1.add(fieldA_B);
        		
        		// B-C 
        		list2.add(dynFlag3);
        		list2.add(query2);
        		list2.add(tab2);
        		list2.add(tab3);
        		list2.add(fieldB_C);
        		
        		//C-D
        		list3.add(dynFlag4);
        		list3.add(query3);
        		list3.add(tab3);
        		list3.add(tab4);
        		list3.add(fieldC_D);
        		
        		//D-A
        		list4.add(dynFlag1);
        		list4.add(query4);
        		list4.add(tab4);
        		list4.add(tab1);
        		list4.add(fieldD_A);
        		
        		//B-A
        		list5.add(dynFlag1);
        		list5.add(queryB_A);
        		list5.add(tab2);
        		list5.add(tab1);
        		list5.add(fieldB_A);
        		
        		//C-B
        		list6.add(dynFlag2);
        		list6.add(queryC_B);
        		list6.add(tab3);
        		list6.add(tab2);
        		list6.add(fieldC_B);
        		
        		//D-C 
        		list7.add(dynFlag3);
        		list7.add(queryD_C);
        		list7.add(tab4);
        		list7.add(tab3);
        		list7.add(fieldD_C);
        		
        		//A-D 
        		list8.add(dynFlag4);
        		list8.add(queryA_D);
        		list8.add(tab1);
        		list8.add(tab4);
        		list8.add(fieldA_D);
        		
        		//C-A
        		list9.add(dynFlag1);
        		list9.add(queryC_A);
        		list9.add(tab3);
        		list9.add(tab1);
        		list9.add(fieldC_A);
        		
        		//D-B
        		list10.add(dynFlag2);
        		list10.add(queryD_B);
        		list10.add(tab4);
        		list10.add(tab2);
        		list10.add(fieldD_B); 
        		
        		//A-C 
        		list11.add(dynFlag3);
        		list11.add(query5);
        		list11.add(tab1);
        		list11.add(tab3);
        		list11.add(fieldA_C); 
        		
        		//B-D 
        		list12.add(dynFlag4);
        		list12.add(query6);
        		list12.add(tab2);
        		list12.add(tab4);
        		list12.add(fieldB_D); 
        		
        		
        		reconMap.put(1, list1); //A-B
        		reconMap.put(2, list5); //B-A
        		reconMap.put(3, list3); //C-D
        		reconMap.put(4, list7); //D-C
        		reconMap.put(5, list11); //A-C        		
        		reconMap.put(6, list9); //C-A
        		reconMap.put(7, list12); //B-D
        		reconMap.put(8, list10); //D-B
        		reconMap.put(9, list8); //A-D
        		reconMap.put(10, list4); //D-A
        		reconMap.put(11, list2); //B-C
        		reconMap.put(12, list6); //C-B
        		
        	}
			logger.info("Ends in fetchReconMap");
		}
		catch(Exception e){
	 	   logger.error("Exception Occured in fetch Recon Map :"+e);
	 	   logger.error("Check Whether the Rules are configured properly ");
	 	  throw new ReconUserDefinedException("Exception occured in fetch Recon Map "+e.getMessage());
		}finally
		{
			map = null;
			objList = null;
			localObject=null;
			databaseService = null;
		}
		
		return reconMap;
	}
	
	
	public Map<Integer, List<String>> fetchReversalUpdateParameter(String processId, LoopBack loopBack)
			throws Exception { 
		String query = "";
		LocalObject localObject = null;
		DatabaseService databaseService=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
		Map<Integer, List<String>> reversalUpdateMap = new HashMap<Integer, List<String>>();
		List<String> list1 = new ArrayList<String>();
		List<String> list2 = new ArrayList<String>();
		List<String> list3 = new ArrayList<String>();
		List<String> list4 = new ArrayList<String>();
		int inputCount = 0;
		try {
			logger.info("Entered into fetchReversalUpdateParameter ");

			query = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.fetchReversalUpdateParameter");
			
			logger.debug("Query to FetchReversalUPdateParameter :"+query);
			
			databaseService = new DatabaseService();
			localObject = new LocalObject();
			if (loopBack != null) {
				localObject.put("LOOPBACK", loopBack);
			}
			localObject.put(1, processId);
			
			objList = databaseService.executeQuery(query, localObject);
			itr = objList.iterator();
			
			while( itr.hasNext() ) {
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;
				
				inputCount = Integer.parseInt( map.get("INPUTCOUNT").toString() );

				list1.add(map.get("TAB1").toString());
				list1.add(map.get("TYPE1").toString()); 
				
				list2.add(map.get("TAB2").toString());
				list2.add(map.get("TYPE2").toString());
				
				list3.add(map.get("TAB3").toString());
				list3.add(map.get("TYPE3").toString());
				
				list4.add(map.get("TAB4").toString());
				list4.add(map.get("TYPE4").toString());
			}

			if( inputCount == 2 ) {
				reversalUpdateMap.put(1, list1);
				reversalUpdateMap.put(2, list2);
			} else if( inputCount == 3 ) {
				reversalUpdateMap.put(1, list1);
				reversalUpdateMap.put(2, list2);
				reversalUpdateMap.put(3, list3);
			} else if( inputCount == 4 ) {
				reversalUpdateMap.put(1, list1);
				reversalUpdateMap.put(2, list2);
				reversalUpdateMap.put(3, list3);
				reversalUpdateMap.put(4, list4);
			}
			
			logger.info("Ends in fetchReversalUpdateParameter ");
		} catch ( Exception e ) {
			logger.error("Exception Occured in fetchReversalUpdateParameter :"+e);
		 	  throw new ReconUserDefinedException("Exception occured in fetchReversalupdateParameters :"+e.getMessage());

		}
	return reversalUpdateMap;	
	}

	// below logic has been moved to Extraction part ..
	@Override
	public int callReversalUpdateProcedure(String dataTable, String fileType, LoopBack loopBack)
			throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		int  status = 0;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("callReversalUpdateProcedure Started"); 

			connection = new DatabaseService().getConnection(loopBack);

				String procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callReversalUpdateProcedure");
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  callReversalUpdateProcedure : " + procedureCall);

				callableStatement.setString(1, dataTable);
				callableStatement.setString(2, fileType);
				callableStatement.registerOutParameter(3, java.sql.Types.VARCHAR);
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(3);
				logger.debug("callReversalUpdateProcedure executed status : " + responseMsg);
				logger.info("callReversalUpdateProcedure arguments  call SP_REVERSAL_UPDATE("+dataTable+", "+fileType+")");
				logger.info("callReversalUpdateProcedure Executed Status for DT  :"+dataTable+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("callReversalUpdateProcedure arguments  call SP_REVERSAL_UPDATE("+dataTable+", "+fileType+")");
					logger.error("callReversalUpdateProcedure Executed Status for DT  :"+dataTable+" = "+responseMsg);
				}
				
				if (responseMsg != null && responseMsg.equals("OK"))
					status = 1;

				Long endTime = System.currentTimeMillis();
			logger.info("Extraction callReversalUpdateProcedure End for DT :"+dataTable); 
			logger.info("Time Taken by callReversalUpdateProcedure for DT :"+dataTable+" = "+(endTime - startTime)/1000);
			
		} catch (Exception e) {
			logger.error("Exception occured in callReversalUpdateProcedure() : " + e);
			throw new ReconUserDefinedException("Exception occured in callReversalUpdateProcedure "+e);
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}

	@Override
	public Map<Integer, List<String>> fetchReconInsertProcedureParameter(
			String processId, LoopBack loopBack) throws Exception { 
		String query = "";
		LocalObject localObject = null;
		DatabaseService databaseService=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
		Map<Integer, List<String>> reconInsertMap = new HashMap<Integer, List<String>>();
		List<String> list1 = new ArrayList<String>();
		List<String> list2 = new ArrayList<String>();
		List<String> list3 = new ArrayList<String>();
		List<String> list4 = new ArrayList<String>();
		int count = 0;
		String dynFlag1 = "";  
		String tab1 =  "";		
		String dynFlag2 =  "";	
		String tab2 =  "";		
		String dynFlag3 =  "";	
		String tab3 =  "";		
		String dynFlag4 =  "";	
		String tab4 =  "";		
		
		try {
			logger.info("Entered into fetchReconInsertProcedureParameter ");
			
			query = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.fetchReconInsertProcedureParameter");
			
			logger.debug("Query to fetchReconInsertProcedureParameter :"+query);
			
			databaseService = new DatabaseService();
			localObject = new LocalObject();
			if (loopBack != null) {
				localObject.put("LOOPBACK", loopBack);
			}
			localObject.put(1, processId);
			
			objList = databaseService.executeQuery(query, localObject);
			itr = objList.iterator();
			
			while( itr.hasNext() ) {
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;
				
				count = Integer.parseInt( map.get("INPUTCOUNT").toString() );
				
				tab1 = map.get("TAB1").toString();
				tab2 = map.get("TAB2").toString();
				tab3 = map.get("TAB3").toString();
				tab4 = map.get("TAB4").toString();
				
				dynFlag1 = map.get("DYNFLAG1").toString();
				dynFlag2 = map.get("DYNFLAG2").toString();
				dynFlag3 = map.get("DYNFLAG3").toString();
				dynFlag4 = map.get("DYNFLAG4").toString();
				
				
			}
			
			if( count == 2 ) {
				list1.add(tab1);
				list1.add(dynFlag2);
				list1.add("");
				list1.add("");
				
				list2.add(tab2);
				list2.add(dynFlag1);
				list2.add("");
				list2.add("");
				
				reconInsertMap.put(1, list1);
				reconInsertMap.put(2, list2);
				
			} else if ( count == 3 ) {
				
				list1.add(tab1);
				list1.add(dynFlag2);
				list1.add(dynFlag3);
				list1.add("");
				
				list2.add(tab2);
				list2.add(dynFlag1);
				list2.add(dynFlag3);
				list2.add("");
				
				list3.add(tab3);
				list3.add(dynFlag1);
				list3.add(dynFlag2);
				list3.add("");
				
				reconInsertMap.put(1, list1);
				reconInsertMap.put(2, list2);
				reconInsertMap.put(3, list3);
				
			} else if ( count == 4 ) {
				list1.add(tab1);
				list1.add(dynFlag2);
				list1.add(dynFlag3);
				list1.add(dynFlag4);
				
				list2.add(tab2);
				list2.add(dynFlag1);
				list2.add(dynFlag3);
				list2.add(dynFlag4);
				
				list3.add(tab3);
				list3.add(dynFlag1);
				list3.add(dynFlag2);
				list3.add(dynFlag4);
				
				list4.add(tab4);
				list4.add(dynFlag1);
				list4.add(dynFlag2);
				list4.add(dynFlag3);
				
				reconInsertMap.put(1, list1);
				reconInsertMap.put(2, list2);
				reconInsertMap.put(3, list3);
				reconInsertMap.put(4, list4);
						
			}
			
			logger.info("Ends in fetchReconInsertProcedureParameter ");
		} catch ( Exception e ) {
			logger.error("Exception Occured in fetchReconInsertProcedureParameter :"+e);
			throw new ReconUserDefinedException("Exception occured in fetchReconInsertProcedureParameter :"+e.getMessage());
		}
	return reconInsertMap;	
	}

	@Override
	public int callReconInsertProcedure(String processId, int inputCount,
			String tabName, String dynFlag1, String dynFlag2, String dynFlag3, LoopBack loopBack)
			throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		int  status = 0;
		String responseMsg = "";
		String procedureCall = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("Recon Insert Procedure Start for DT :"+tabName); // Added by Mohan Raj.V to log Time

			connection = new DatabaseService().getConnection(loopBack);

			procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callReconInsertProcedure");

				
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  SP_RECON_INSERT_BENCH Procedure : " + procedureCall);

				callableStatement.setLong(1, Long.parseLong(processId));
				callableStatement.setInt(2, inputCount);
				callableStatement.setString(3, tabName);
				callableStatement.setString(4, dynFlag1);
				callableStatement.setString(5, dynFlag2);
				callableStatement.setString(6, dynFlag3);
				
				
				callableStatement.registerOutParameter(7, java.sql.Types.VARCHAR);
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(7);
				logger.debug("SP_RECON_INSERT procedure  executed status : " + responseMsg);
				logger.info("SP_RECON_INSERT arguments  call SP_RECON_INSERT_BENCH("+processId+", "+inputCount+", "+tabName+", "+dynFlag1+", "+dynFlag2+", "+dynFlag3+")");
				logger.info("SP_RECON_INSERT Executed Status for DT  :"+tabName+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("SP_RECON_INSERT arguments  call SP_RECON_INSERT_BENCH("+processId+", "+inputCount+", "+tabName+", "+dynFlag1+", "+dynFlag2+", "+dynFlag3+")");
					logger.error("SP_RECON_INSERT Executed Status for DT  :"+tabName+" = "+responseMsg);
				}
				if (responseMsg != null && responseMsg.equals("OK"))
					status = 1;

				Long endTime = System.currentTimeMillis();
			logger.info("Extraction SP_RECON_INSERT End for DT :"+tabName); 
			logger.info("Time Taken by SP_RECON_INSERT for DT :"+tabName+" = "+(endTime - startTime)/1000);

		} catch (Exception e) {
			logger.error("Exception occured in SP_RECON_INSERT_BENCH() : " + e);
			throw new ReconUserDefinedException("Exception occured in SP_RECON_INSERT_BENCH "+e); //SP_ONE2ONE_RECON_BENCH
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}

	@Override
	public int callRankCreationProcedure(String dataTable, String matchingField, LoopBack loopBack) throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		int  status = 0;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("callRankCreationProcedure Started"); 

			connection = new DatabaseService().getConnection(loopBack);

				String procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callRankCreationProcedure");
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  callRankCreationProcedure : " + procedureCall);

				callableStatement.setString(1, dataTable);
				callableStatement.setString(2, matchingField);
				callableStatement.registerOutParameter(3, java.sql.Types.VARCHAR);
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(3);
				logger.debug("callRankCreationProcedure executed status : " + responseMsg);
				logger.info("callRankCreationProcedure arguments  call SP_CREATE_RANK_BENCH("+dataTable+", "+matchingField+")");
				logger.info("callRankCreationProcedure Executed Status for DT  :"+dataTable+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("callRankCreationProcedure arguments  call SP_CREATE_RANK_BENCH("+dataTable+", "+matchingField+")");
					logger.error("callRankCreationProcedure Executed Status for DT  :"+dataTable+" = "+responseMsg);
				}
				if (responseMsg != null && responseMsg.equals("OK"))
					status = 1;

				Long endTime = System.currentTimeMillis();
			logger.info("Extraction callRankCreationProcedure End for DT :"+dataTable); 
			logger.info("Time Taken by callRankCreationProcedure for DT :"+dataTable+" = "+(endTime - startTime)/1000);
			
		} catch (Exception e) {
			logger.error("Exception occured in callRankCreationProcedure() : " + e);
			throw new ReconUserDefinedException("Exception occured in callRankCreationProcedure "+e);
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}

	@Override
	public boolean callRankDropProcedure(String processId, String comUncomFlag,
			String dataTable1, String dataTable2, LoopBack loopBack)
			throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		boolean  status = false;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("callRankDropProcedure Started"); 

			connection = new DatabaseService().getConnection(loopBack);

				String procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callRankDropProcedure");
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  callRankDropProcedure : " + procedureCall);

				callableStatement.setString( 1, processId );
				callableStatement.setString( 2, comUncomFlag );
				callableStatement.setString( 3, dataTable1 );
				callableStatement.setString( 4, dataTable2 );
				callableStatement.registerOutParameter( 5, java.sql.Types.VARCHAR );
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(5);
				logger.debug("callRankDropProcedure executed status : " + responseMsg);
				logger.info("callRankDropProcedure arguments  call SP_DROP_RANK_BENCH("+processId+", "+comUncomFlag+","+dataTable1+","+dataTable2+ ")");
				logger.info("callRankDropProcedure Executed Status for DT  :"+dataTable1+","+dataTable2+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("callRankDropProcedure arguments  call SP_DROP_RANK_BENCH("+processId+", "+comUncomFlag+","+dataTable1+","+dataTable2+ ")");
					logger.error("callRankDropProcedure Executed Status for DT  :"+dataTable1+","+dataTable2+" = "+responseMsg);
				}
				
				if (responseMsg != null && responseMsg.equals("OK"))
					status = true;

				Long endTime = System.currentTimeMillis();
			logger.info("Extraction callRankDropProcedure End for DT :"+dataTable1+","+dataTable2); 
			logger.info("Time Taken by callRankDropProcedure for DT :"+dataTable1+","+dataTable2+" = "+(endTime - startTime)/1000);
			
		} catch (Exception e) {
			logger.error("Exception occured in callRankDropProcedure() : " + e);
			throw new ReconUserDefinedException("Exception occured in callRankDropProcedure "+e);
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}

	@Override
	public String fetchComUncommFlag(String processId, LoopBack loopBack)
			throws Exception {
		
		LocalObject localObject = null;
        DatabaseService databaseService=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
        String result = "";
        
		try
		{
			logger.info("Fetch common or uncommon Flag method Starts");
			
			String query = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.fetchCommonUncommonFlag");

			databaseService = new DatabaseService();
        	localObject = new LocalObject();
        	if (loopBack != null) {
				localObject.put("LOOPBACK", loopBack);
			}
        	localObject.put(1, processId);

        	objList=databaseService.executeQuery(query, localObject);
        	itr = objList.iterator();
        	while (itr.hasNext()) 
			{
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;
				
				result = map.get("MATCHINGFLAG").toString();
			}		
			
		}
		catch(Exception e){
	           
     	   logger.error("Exception Occured during fetch common or uncommon flag :"+e.getMessage());
     	   throw new ReconUserDefinedException("Exception Occured while fetching matching Flag :"+e.getMessage());
        }finally
	        {
	        	map = null;
	    		objList = null;
	    		localObject=null;
	    		databaseService = null;
	        }
		
	        logger.info("Fetch common or uncommon Flag method ends");
		return result;
	}
	//Added by Nancy to show pop up for recon status 
	@Override
	public List<Map<String, String>> getReportStatus(String processid,
			String reportStatus) throws Exception {
		LocalObject localObject = null;
		Iterator<LocalObject> objIterator = null;
		Map<Object, Object> map = new HashMap<Object, Object>();
		Map<String, String>  recordFieldsMap =  new HashMap<String, String>();
		Map<Object, Object> recordFieldsMapTemp = new HashMap<Object, Object>();
		List<Map<String, String>>recordFieldsList = new ArrayList<Map<String,String>>();
		Map<String, String> recordFieldsMaprecon = new HashMap<String, String>();
		
		List<LocalObject> listLocalObject = null;
		String query="";
		String recon_query="";
		String unRecon_query1 = "";
		String recon_Type = "";
		
		try {
			logger.info("Entered into getReportStatus in DaoImpl");
			
			
			localObject = new LocalObject();
			if(reportStatus.equalsIgnoreCase("Error")){
				query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.GET.ERROR_DESC");
				localObject.put(1, processid);
				localObject.put(2, "E");
			}else if(reportStatus.equalsIgnoreCase("Completed")){
				query = QueryPropertyUtil.getProperty("DB.RECONCILIATION.GET.PROCESS_DTLS");
				localObject.put(1, processid);
			}
			
			logger.debug("Query to getReportStatus :" + query);
			dbService = new DatabaseService();
			
			
			listLocalObject = dbService.executeQuery(query, localObject);
			
			objIterator = listLocalObject.iterator();

			if (listLocalObject.size() > 0) {
				while (objIterator.hasNext()) {
					localObject = (LocalObject) objIterator.next();
					map = localObject.getMap();
					if(reportStatus.equalsIgnoreCase("Error")){
						recordFieldsMap.put(("Error Desc"), map.get("ERROR_DESC").toString());
						recordFieldsList.add(recordFieldsMap);
					}else{
						recordFieldsMapTemp.put(("INPUT_COUNT"), map.get("INPUT_COUNT").toString());
						recordFieldsMapTemp.put(("FLAG_NAME1"), map.get("FLAG_NAME1").toString());
						recordFieldsMapTemp.put(("FLAG_NAME2"), map.get("FLAG_NAME2").toString());
						recordFieldsMapTemp.put(("FLAG_NAME3"), map.get("FLAG_NAME3").toString());
						recordFieldsMapTemp.put(("FLAG_NAME4"), map.get("FLAG_NAME4").toString());
						recordFieldsMapTemp.put(("DATA_TAB_NAME1"), map.get("DATA_TAB_NAME1").toString());
						recordFieldsMapTemp.put(("DATA_TAB_NAME2"), map.get("DATA_TAB_NAME2").toString());
						recordFieldsMapTemp.put(("DATA_TAB_NAME3"), map.get("DATA_TAB_NAME3").toString());
						recordFieldsMapTemp.put(("DATA_TAB_NAME4"), map.get("DATA_TAB_NAME4").toString());
						
					}
					
					
				}
			}

			if(reportStatus.equalsIgnoreCase("Error")){
			
			}else{
				
				
				if(recordFieldsMapTemp.get("INPUT_COUNT").equals("2") ){
					recon_Type= "Two Way Reconciliation";
					recon_query = "SELECT min (T1) as RECON_COUNT FROM (SELECT COUNT(1) T1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME1")+
							" A  where a.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME2")+" B  where B.REC_FLG='1')";
					
					unRecon_query1= "SELECT 'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME1")+"' UREC_TITLE1,(SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME1")+" A WHERE A.REC_FLG ='0') URECOUNT1,"+
							"'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME2")+"' UREC_TITLE2, (SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME2")+" B WHERE B.REC_FLG ='0') URECOUNT2 FROM DUAL ";
				}else if(recordFieldsMapTemp.get("INPUT_COUNT").equals("3") ){
					recon_Type= "Three Way Reconciliation";
					recon_query = "SELECT min (T1) as RECON_COUNT FROM (SELECT COUNT(1) T1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME1")+
							" A  where A.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME2")+
							" B  where B.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME3")+" C  where C.REC_FLG='1')";
					unRecon_query1= "SELECT 'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME1")+"' UREC_TITLE1,(SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME1")+" A WHERE A.REC_FLG ='0') URECOUNT1,"+
										   "'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME2")+"' UREC_TITLE2,(SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME2")+" B WHERE B.REC_FLG ='0') URECOUNT2,"+
										   "'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME3")+"' UREC_TITLE3,(SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME3")+" C WHERE C.REC_FLG ='0') URECOUNT3 FROM DUAL ";
				}else{
					recon_Type= "Four Way Reconciliation";
					recon_query = "SELECT min (T1) as  RECON_COUNT FROM (SELECT COUNT(1) T1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME1")+
							" A  where A.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME2")+
							" B  where B.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME3")+
							" C  where C.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME4")+" D  where D.REC_FLG='1')";
					unRecon_query1= "SELECT 'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME1")+"' UREC_TITLE1,(SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME1")+" A WHERE A.REC_FLG ='0') URECOUNT1,"+
							               "'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME2")+"' UREC_TITLE2,(SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME2")+" B WHERE B.REC_FLG ='0') URECOUNT2,"+
							               "'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME3")+"' UREC_TITLE3,(SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME3")+" C WHERE C.REC_FLG ='0') URECOUNT3,"+
							               "'Present only in '||'"+recordFieldsMapTemp.get("DATA_TAB_NAME4")+"' UREC_TITLE4,(SELECT COUNT(1) FROM "+recordFieldsMapTemp.get("DATA_TAB_NAME4")+" D WHERE C.REC_FLG ='0') URECOUNT4 FROM DUAL ";
							
				}
				recordFieldsMap.clear();
				listLocalObject = null;
				localObject = new LocalObject();
				listLocalObject = dbService.executeQuery(recon_query, localObject);
				
				
				objIterator = listLocalObject.iterator();

				if (listLocalObject.size() > 0) {
					while (objIterator.hasNext()) {
						localObject = (LocalObject) objIterator.next();
						map = localObject.getMap();
						recordFieldsMaprecon.put(("Recon Count"), map.get("RECON_COUNT").toString());
						recordFieldsList.add(recordFieldsMaprecon);
						
					}
				}
				recordFieldsMaprecon = new HashMap<String, String>();
				recordFieldsMaprecon.put(("Reconciliation Type"), recon_Type);
				recordFieldsList.add(recordFieldsMaprecon);
				/*listLocalObject = null;
				localObject = new LocalObject();
				listLocalObject = dbService.executeQuery(unRecon_query1, localObject);
				
				
				objIterator = listLocalObject.iterator();

				if (listLocalObject.size() > 0) {
					while (objIterator.hasNext()) {
						localObject = (LocalObject) objIterator.next();
						map = localObject.getMap();
						recordFieldsMap.put(map.get("UREC_TITLE1").toString(), map.get("URECOUNT1").toString());
						recordFieldsMap.put(map.get("UREC_TITLE2").toString(), map.get("URECOUNT2").toString());
						//recordFieldsMap.put(map.get("UREC_TITLE3").toString(), map.get("URECOUNT3").toString());
						//recordFieldsMap.put(map.get("UREC_TITLE4").toString(), map.get("URECOUNT4").toString());
						recordFieldsList.add(recordFieldsMap);
						
					}
				}*/
			}
			
			
			logger.info("getReportStatus ends in ServiceImpl");
 		} catch (Exception e) {
			logger.error("Exception Occured in getReportStatus block : " + e);
		} finally {
			localObject = null;
			listLocalObject = null;
			map = null;
		}

		return recordFieldsList;
	
	}
	//Added by Nancy for recon_details insertion in rcn_recon_dtl
	@Override
	public boolean insertReconDtls(String processId, String processName,
			String startTime, String endTime, String userId,
			String roleName, String institutionName, String reconStatus,
			boolean reportGenerationStatus,String Recon_Mode,LoopBack loopBack) throws Exception {
		
		boolean status = false;
		LocalObject localObject = null;
        DatabaseService databaseService=null;
        Connection connection=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
        String inputCount= "";
        String reconType = "";
        String query="";
        String recon_query = "";
        String dataTable1 = "";
        String dataTable2 = "";
        String dataTable3 = "";
        String dataTable4 = "";
        String recon_count = "";
        
        try{
        	logger.info("Entered into insertReconDtls daoimpl..");
        	query = QueryPropertyUtil.getProperty("DB.GET.RECON.INPUT_COUNT");
        	
        	logger.debug("query to get recon input type count"+query);
        	
        	
        	databaseService = new DatabaseService();
        	localObject = new LocalObject();
        	if (loopBack != null) {
				localObject.put("LOOPBACK", loopBack);
			}
        	localObject.put(1, processId);

        	objList=databaseService.executeQuery(query, localObject);
        	itr = objList.iterator();
        	while (itr.hasNext()) 
			{
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;
				
				inputCount = map.get("INPUT_COUNT").toString();
				
				if(inputCount.equalsIgnoreCase("2")){
					dataTable1 = map.get("TABLE1").toString();
					dataTable2 = map.get("TABLE2").toString();
					
					reconType = "TWO WAY RECONCILIATION";
					recon_query = "SELECT MAx (T1) as RECON_COUNT FROM (SELECT COUNT(1) T1 FROM "+dataTable1+
							" A  where a.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+dataTable2+" B  where B.REC_FLG='1')";
				}else if(inputCount.equalsIgnoreCase("3")){
					dataTable1 = map.get("TABLE1").toString();
					dataTable2 = map.get("TABLE2").toString();
					dataTable3 = map.get("TABLE3").toString();
					
					reconType = "THREE WAY RECONCILIATION";
					recon_query = "SELECT MAx (T1) as RECON_COUNT FROM (SELECT COUNT(1) T1 FROM "+dataTable1+
							" A  where A.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+dataTable2+
							" B  where B.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+dataTable3+" C  where C.REC_FLG='1')";
				}else if(inputCount.equalsIgnoreCase("4")){
					dataTable1 = map.get("TABLE1").toString();
					dataTable2 = map.get("TABLE2").toString();
					dataTable3 = map.get("TABLE3").toString();
					dataTable4 = map.get("TABLE4").toString();
					
					reconType = "FOUR WAY RECONCILIATION";
					recon_query = "SELECT MAx (T1)  as RECON_COUNT FROM (SELECT COUNT(1) T1 FROM "+dataTable1+
							" A  where A.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+dataTable2+
							" B  where B.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+dataTable3+
							" C  where C.REC_FLG='1' UNION ALL SELECT COUNT(1) t1 FROM "+dataTable4+" D  where D.REC_FLG='1')";
				}
			}		
			if(reconStatus.equalsIgnoreCase("C")){
				
				reconStatus= "Completed";
				localObject = new LocalObject();
				if (loopBack != null) {
					localObject.put("LOOPBACK", loopBack);
				}
	        	objList=databaseService.executeQuery(recon_query, localObject);
	        	itr = objList.iterator();
	        	while (itr.hasNext()) 
				{
					localObject = (LocalObject) itr.next();
					map = localObject.getMap();
					localObject = null;
					
					recon_count = map.get("RECON_COUNT").toString();
				}
			}else{
				reconStatus= "Failed";
				recon_count = "0";
			}
        	
			
			try{
				query = QueryPropertyUtil.getProperty("DB.INSERT.RECON_DTLS");
				logger.debug("query to insertrecondtl..:"+query);
				String reportStatus = (reportGenerationStatus ? "Completed":"Failed");
				localObject = new LocalObject();
				connection=databaseService.getDBConnectionWithInstitutionName(institutionName);
				
				localObject.put(1, processId);
				localObject.put(2, processName);
				localObject.put(3, startTime);
				localObject.put(4, endTime);
				localObject.put(5, userId);
				localObject.put(6, roleName);
				localObject.put(7, inputCount);
				localObject.put(8, reconType);
				localObject.put(9, reconStatus);
				localObject.put(10, reportStatus);
				localObject.put(11, recon_count);
				localObject.put(12, Recon_Mode);
				
				int count = databaseService.executeUpdate(query, localObject, connection);
				
				if(count > 0){
					status = true;
				}
				
			}catch(Exception e){
				logger.error("Exception Occurred during insertrecondtls "+e);
			}
        } catch(Exception e){
        	logger.error("Exception Occurred while getting RECON DEATAILS in insertReconDtls  "+e);
        } finally {
        	if(databaseService != null)
        		databaseService.closeConnection(connection);
        }
		return status;
	}


	@Override
	public Map<Integer, List<String>> fetchRollBackParameters(String processId,
			LoopBack loopBack) throws Exception { 
		String query = "";
		LocalObject localObject = null;
		DatabaseService databaseService=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
		List<String> rollBackList1 = new ArrayList<String>();
		List<String> rollBackList2 = new ArrayList<String>();
		List<String> rollBackList3 = new ArrayList<String>();
		List<String> rollBackList4 = new ArrayList<String>();
		
		Map< Integer,List<String> > rollBackMap = new HashMap< Integer, List<String> >();
		try {
			logger.info("Entered into fetchRollBackParameters ");

			query = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.fetchRollBackParameter");
			
			logger.debug("Query to fetchRollBackParameters :"+query);
			
			databaseService = new DatabaseService();
			localObject = new LocalObject();
			if (loopBack != null) {
				localObject.put("LOOPBACK", loopBack);
			}
			localObject.put(1, processId);
			
			objList = databaseService.executeQuery(query, localObject);
			itr = objList.iterator();
			
			while( itr.hasNext() ) {
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;
				
//				rollBackList1.add(  map.get("INPUTCOUNT").toString() );

				rollBackList1.add(  map.get("TAB1").toString() );
				rollBackList1.add(  map.get("DYNFLAG2").toString() );
				rollBackList1.add(  map.get("DYNFLAG3").toString() );
				rollBackList1.add(  map.get("DYNFLAG4").toString() );
				
				rollBackList2.add(  map.get("TAB2").toString() );
				rollBackList2.add(  map.get("DYNFLAG1").toString() );
				rollBackList2.add(  map.get("DYNFLAG3").toString() );
				rollBackList2.add(  map.get("DYNFLAG4").toString() );
				
				rollBackList3.add(  map.get("TAB3").toString() );
				rollBackList3.add(  map.get("DYNFLAG1").toString() );
				rollBackList3.add(  map.get("DYNFLAG2").toString() );
				rollBackList3.add(  map.get("DYNFLAG4").toString() );
				
				rollBackList4.add(  map.get("TAB4").toString() );
				rollBackList4.add(  map.get("DYNFLAG1").toString() );
				rollBackList4.add(  map.get("DYNFLAG2").toString() );
				rollBackList4.add(  map.get("DYNFLAG3").toString() );
				
				
				
				rollBackMap.put(1, rollBackList1);
				rollBackMap.put(2, rollBackList2);
				rollBackMap.put(3, rollBackList3);
				rollBackMap.put(4, rollBackList4);
				
			}

			logger.info("Ends in fetchRollBackParameters ");
		} catch ( Exception e ) {
			logger.error("Exception Occured in fetchRollBackParameters :"+e);
		 	  throw new ReconUserDefinedException("Exception occured in fetchRollBackParameters :"+e.getMessage());

		}
	return rollBackMap;	
	}

/*	@Override
	public int callRollBackProcedure(String dataTable, int count,
			String dynFlag1, String dynFlag2, String dynFlag3, LoopBack loopBack)
			throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		int  status = 0;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("callRollBackProcedure Started"); 

			connection = new DatabaseService().getConnection(loopBack);

				String procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callRollBackProcedure");
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  callRollBackProcedure : " + procedureCall);

				callableStatement.setString( 1, dataTable );
				callableStatement.setInt( 2, count );
				callableStatement.setString( 3, dynFlag1 );
				callableStatement.setString( 4, dynFlag2 );
				callableStatement.setString( 5, dynFlag3 );
				callableStatement.registerOutParameter( 6, java.sql.Types.VARCHAR );
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(6);
				logger.debug("callRollBackProcedure executed status : " + responseMsg);
				logger.info("callRollBackProcedure arguments  call SP_ROLLBACK_UPDATE("+dataTable+", "+count+","+dynFlag1+","+dynFlag2+","+dynFlag3+")");
				logger.info("callRollBackProcedure Executed Status for DT  :"+dataTable+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("callRollBackProcedure arguments  call SP_ROLLBACK_UPDATE("+dataTable+", "+count+","+dynFlag1+","+dynFlag2+","+dynFlag3+")");
					logger.error("callRollBackProcedure Executed Status for DT  :"+dataTable+" = "+responseMsg);
				}
				
				if (responseMsg != null && responseMsg.equals("OK"))
					status = 1;

				Long endTime = System.currentTimeMillis();
			logger.info("Time Taken by callRollBackProcedure for DT :"+dataTable+" = "+(endTime - startTime)/1000);
			
		} catch (Exception e) {
			logger.error("Exception occured in callRollBackProcedure() : " + e);
			throw new ReconUserDefinedException("Exception occured in callRollBackProcedure "+e);
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}*/

	@Override
	public int callRollBackProcedure(String processId, String rollBkStatus,
			LoopBack loopBack) throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		int  status = 0;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("callRollBackProcedure Started"); 
			
			if( "Y".equals( rollBkStatus ) )
				logger.info("callRollBackProcedure Started for Sucess Case Droping temp Table");
			else 
				logger.info("callRollBackProcedure Started for Failure Case Drop and rename temp Table");
			
			connection = new DatabaseService().getConnection(loopBack);

				String procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callLatestRollBackProcedure");
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  callRollBackProcedure : " + procedureCall);

				callableStatement.setString( 1, processId );
				callableStatement.setString( 2, rollBkStatus );
				callableStatement.registerOutParameter( 3, java.sql.Types.VARCHAR );
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(3);
				logger.debug("callRollBackProcedure executed status : " + responseMsg);
				logger.info("callRollBackProcedure arguments  call SP_ROLLBACK_BENCH("+processId+", "+rollBkStatus+")");
				logger.info("callRollBackProcedure Executed Status for process Id  :"+processId+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("callRollBackProcedure arguments  call SP_ROLLBACK_BENCH("+processId+", "+rollBkStatus+")");
					logger.error("callRollBackProcedure Executed Status for process Id  :"+processId+" = "+responseMsg);
				}
				
				if (responseMsg != null && responseMsg.equals("OK"))
					status = 1;

				Long endTime = System.currentTimeMillis();
			logger.info("Time Taken by callRollBackProcedure for processId :"+processId+" = "+(endTime - startTime)/1000);
			
		} catch (Exception e) {
			logger.error("Exception occured in callRollBackProcedure() : " + e);
			throw new ReconUserDefinedException("Exception occured in callRollBackProcedure "+e);
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}

	@Override
	public int callDataTableBackupProcedure(String dataTable, LoopBack loopBack)
			throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		int  status = 0;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("callDataTableBackupProcedure Started"); 

			connection = new DatabaseService().getConnection(loopBack);

				String procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callDataTableBackupProcedure");
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  callDataTableBackupProcedure : " + procedureCall);

				callableStatement.setString( 1, dataTable );
				callableStatement.registerOutParameter( 2, java.sql.Types.VARCHAR );
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(2);
				logger.debug("callDataTableBackupProcedure executed status : " + responseMsg);
				logger.info("callDataTableBackupProcedure arguments  call SP_CREATE_DATA_BCUP_BENCH("+dataTable+")");
				logger.info("callDataTableBackupProcedure Executed Status for dataTable  :"+dataTable+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("callDataTableBackupProcedure arguments  call SP_CREATE_DATA_BCUP_BENCH("+dataTable+")");
					logger.error("callDataTableBackupProcedure Executed Status for dataTable  :"+dataTable+" = "+responseMsg);
				}
				
				if (responseMsg != null && responseMsg.equals("OK"))
					status = 1;

				Long endTime = System.currentTimeMillis();
			logger.info("Time Taken by callDataTableBackupProcedure for processId :"+dataTable+" = "+(endTime - startTime)/1000);
			
		} catch (Exception e) {
			logger.error("Exception occured in callDataTableBackupProcedure() : " + e);
			throw new ReconUserDefinedException("Exception occured in callDataTableBackupProcedure "+e);
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}

	@Override
	public boolean callSecondaryMatchingProcedure(String processId, int count, LoopBack loopBack)
			throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		boolean  status = false;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("callSecondaryMatchingProcedure Started"); 

			connection = new DatabaseService().getConnection(loopBack);

				String procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callSecondaryMatchingProcedure");
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  callSecondaryMatchingProcedure : " + procedureCall);

				callableStatement.setString( 1, processId );
				callableStatement.setInt( 2, count );
				callableStatement.registerOutParameter( 3, java.sql.Types.VARCHAR );
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(3);
				logger.debug("callSecondaryMatchingProcedure executed status : " + responseMsg);
				logger.info("callSecondaryMatchingProcedure arguments  call SP_SECNDRY_MATCH_BENCH("+processId+", "+count+ ")");
				logger.info("callSecondaryMatchingProcedure Executed Status for DT  :"+processId+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("callSecondaryMatchingProcedure arguments  call SP_SECNDRY_MATCH_BENCH("+processId+", "+count+ ")");
					logger.error("callSecondaryMatchingProcedure Executed Status for DT  :"+processId+" = "+responseMsg);
				}
				
				if (responseMsg != null && responseMsg.equals("OK"))
					status = true;

				Long endTime = System.currentTimeMillis();
			logger.info("Time Taken by callSecondaryMatchingProcedure for DT :"+processId+" = "+(endTime - startTime)/1000);
			
		} catch (Exception e) {
			logger.error("Exception occured in callSecondaryMatchingProcedure() : " + e);
			throw new ReconUserDefinedException("Exception occured in callSecondaryMatchingProcedure "+e);
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}

		return status;
	}

	@Override
	public boolean fetchLastProcessStatus(String processId, LoopBack loopBack)
			throws Exception {
		
		String query =  "";
		boolean insertStatus = false;
		LocalObject localObject = null;
        DatabaseService databaseService=null;
        Connection connection=null;
		try
		{
			logger.info(" Enter into fetch last Process run status ");
			
			query = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.fetchLastProcessStatus");
			
	        logger.debug("Query to fetchLastProcessStatus  "+query);

			
			databaseService = new DatabaseService();
        	localObject = new LocalObject(); 
			localObject.put(1, processId); 
			
			if(loopBack != null) {
				localObject.put("LOOPBACK", loopBack);
			}
			
			int count = databaseService.executeUpdate(query,localObject,connection);
        	if (count > 0) 
			{
				localObject = null;
				insertStatus = true;
			}
        	
        	logger.info("Ends in fetchLastProcessStatus ");
        }catch(Exception e){
        	logger.error("Exception occured in fetchLastProcessStatus ",e);
        }finally
        {
    		localObject=null;
    		databaseService = null;
    		if(connection!=null)
    			connection.close();
        }

		return insertStatus;
	
}

	@Override
	public int callReconProcessResetProcedure( String dataTable, int inputCount ,String dynFlag1, String dynFlag2, String dynFlag3, LoopBack loopBack ) throws Exception {

		Connection connection = null;
		CallableStatement callableStatement = null;
		int  status = 0;
		String responseMsg = "";

		try {
			Long startTime = System.currentTimeMillis();
			logger.info("callReconProcessResetProcedure Started"); 

			connection = new DatabaseService().getConnection(loopBack);

				String procedureCall = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.callReconProcessResetProcedure");
				callableStatement = connection.prepareCall(procedureCall);
				logger.debug("calling the  callReconProcessResetProcedure : " + procedureCall);

				callableStatement.setString( 1, dataTable );
				callableStatement.setInt( 2, inputCount );
				callableStatement.setString( 3, dynFlag1 );
				callableStatement.setString( 4, dynFlag2 );
				callableStatement.setString( 5, dynFlag3 );
				callableStatement.registerOutParameter( 6, java.sql.Types.VARCHAR );
				callableStatement.executeUpdate();

				responseMsg = callableStatement.getString(6);
				logger.debug("callReconProcessResetProcedure executed status : " + responseMsg);
				logger.info("callReconProcessResetProcedure arguments  call SP_RESET_DYN_FLG("+dataTable+","+inputCount+","+dynFlag1+","+dynFlag2+","+dynFlag3+")");
				logger.info("callReconProcessResetProcedure Executed Status for DT  :"+dataTable+" = "+responseMsg);
				
				if(!"OK".equalsIgnoreCase(responseMsg)) {
					logger.error("callReconProcessResetProcedure arguments  call SP_RESET_DYN_FLG("+dataTable+","+inputCount+","+dynFlag1+","+dynFlag2+","+dynFlag3+")");
					logger.error("callReconProcessResetProcedure Executed Status for DT  :"+dataTable+" = "+responseMsg);
				}
				
				if (responseMsg != null && responseMsg.equals("OK"))
					status = 1;

				Long endTime = System.currentTimeMillis();
			logger.info("Time Taken by callReconProcessResetProcedure for DT :"+dataTable+" = "+(endTime - startTime)/1000);
			
		} catch (Exception e) {
			status = 0;
			logger.error("Exception occured in callReconProcessResetProcedure() : " , e);
			throw new ReconUserDefinedException("Exception occured in callReconProcessResetProcedure "+e);
		} finally {
			try {
				if (callableStatement != null && !callableStatement.isClosed())
					callableStatement.close();

				if (connection != null && !connection.isClosed())
					connection.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " , e);
			}
		}

		return status;
	}

	@Override
	public Map<String, String> fetchReverUpdateIndicator(String processId,
			LoopBack loopBack) throws Exception { 
		String query = "";
		LocalObject localObject = null;
		DatabaseService databaseService=null;
        List<LocalObject> objList = null;
        Iterator<LocalObject> itr = null;
        Map<Object, Object> map = new HashMap<Object, Object>();
		Map<String,String> reversalIndicatorMap = new HashMap<String,String>();
		int inputCount = 0;
		try {
			logger.info("Entered into fetchReverUpdateIndicator ");

			query = QueryPropertyUtil.getProperty("rcn.recon.reconciliationProcess.fetchReverUpdateIndicator");
			
			logger.debug("Query to fetchReverUpdateIndicator :"+query);
			
			databaseService = new DatabaseService();
			localObject = new LocalObject();
			if (loopBack != null) {
				localObject.put("LOOPBACK", loopBack);
			}
			localObject.put(1, processId);
			localObject.put(2, 1); //sub template id(default we are considering main template
			
			objList = databaseService.executeQuery(query, localObject);
			itr = objList.iterator();
			
			while( itr.hasNext() ) {
				localObject = (LocalObject) itr.next();
				map = localObject.getMap();
				localObject = null;

				reversalIndicatorMap.put(map.get("TABLE_NAME").toString() , map.get("INDICATOR").toString());
			}

			logger.info("Ends in fetchReverUpdateIndicator ");
		} catch ( Exception e ) {
			logger.error("Exception Occured in fetchReverUpdateIndicator :",e);
		 	  throw new ReconUserDefinedException("Exception occured in fetchReverUpdateIndicators :"+e.getMessage());

		}
	return reversalIndicatorMap;	
	}


}

