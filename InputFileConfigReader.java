 package com.fss.recon.core.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.Future;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fss.recon.core.dao.InputFileReaderDao;
import com.fss.recon.core.exception.ReconUserDefinedException;
import com.fss.recon.core.factory.Reader;
import com.fss.recon.core.form.DrIdentificationForm;
import com.fss.recon.core.form.FooterConfiguration;
import com.fss.recon.core.form.InputFileConfigurationForm;
import com.fss.recon.core.form.TemplateForm;
import com.fss.recon.core.model.KeyBasedDataRecord;
import com.fss.recon.crypto.KeyCache;
import com.fss.recon.crypto.SecurityUtils;

@Service
public class InputFileConfigReader extends Reader implements Callable<Integer> {
	
	@Autowired
	private InputFileReaderDao readerDao;

	@Autowired
	private HeaderValidation headerValidation;

	@Autowired
	private FooterValidation footerValidation;
	
	public InputFileConfigReader() {
		// TODO Auto-generated constructor stub
	}
	
	InputFileConfigurationForm inputForm = null;
	String fileName = null;
	Map<String, TemplateForm> templateConfigMap = null;
	LoopBack loopBack = null;
	Map<String, String> fileNameDtls = null;
	
	/*@Autowired
	private AutowireCapableBeanFactory beanFactory;*/

	public InputFileConfigReader(InputFileConfigurationForm inputForm,String fileName, Map<String, TemplateForm> templateConfigMap,LoopBack loopBack, Map<String, String> fileNameDtls,InputFileReaderDao readerDao,
			HeaderValidation headerValidation, FooterValidation footerValidation ) {
		this.inputForm = inputForm;
		this.fileName = fileName;
		this.templateConfigMap = templateConfigMap;
		this.loopBack = loopBack;
		this.fileNameDtls = fileNameDtls;
		this.readerDao = readerDao;
		this.headerValidation = headerValidation;
		this.footerValidation = footerValidation;

	}
	
	Logger logger = Logger.getLogger("InputFileConfigReader");
	ArrayList<Object> calculatedValues = new ArrayList<Object>();
	Map<Long, Double> counter = null;//modified by nancy on 03-05-16 to initilize from 0
	Map<String, Integer> m = new HashMap<String, Integer>();
	public String terminalId = ""; //Added by Mohan Raj.V on 29-03-2016 to save terminal id for admin EJ Transaction	

	
	//private List<Future<Integer>> futures = new ArrayList<Future<Integer>> ();	
	
	

	
	

	/**Read Single file and create DAT files and Store them in DB 
	 * @param inputForm Input file configuration form
	 * @param fileName File Name
	 * @param templateConfigMap Map for template configuration
	 * @param loopBack LoopBack reference
	 * @throws ReconUserDefinedException
	 */
	
	public void readFile(InputFileConfigurationForm inputForm, String fileName,
			Map<String, TemplateForm> templateConfigMap, LoopBack loopBack, Map<String, String> fileNameDtls) throws ReconUserDefinedException {
		
		InputFileConfigReader configReader = new InputFileConfigReader(inputForm,fileName,templateConfigMap,loopBack,fileNameDtls,readerDao, headerValidation, footerValidation);
//		beanFactory.autowireBean(configReader);
		
//		System.out.println(beanFactory.getClass());
		//this.futures.add(this.getExecutorService().submit(configReader));
		//this.setFutures(futures);
		// 
		
		if(!this.futureMap.containsKey(inputForm.getFileId()))
			futureMap.put(inputForm.getFileId(),  new ArrayList<Future<Integer>> ());
				
		
		List<Future<Integer>> futures = futureMap.get(inputForm.getFileId());
		futures.add(this.getExecutorService().submit(configReader));
		futureMap.put(inputForm.getFileId(), futures);
		
		this.setFutureMap(futureMap);
		
	}

	/**
	 * read Variable Formatted File
	 * 
	 * @param fileName
	 *            File Name
	 * @param inputForm
	 *            Input file configuration form
	 * @param bufferWritermap
	 *            map for DAT File writer
	 * @param templateConfigMap
	 *            Map for template configuration
	 * @return boolean true or false
	 * @throws ReconUserDefinedException
	 */
	public Boolean readVariableBasedFile(String fileName, InputFileConfigurationForm form,
			Map<String, BufferedWriter> bufferWritermap, Map<String, TemplateForm> templateConfigMap,LoopBack loopBack, Map<String, String> fileNameDtls)
					throws ReconUserDefinedException {

		char pcData[];
		Integer piOffset = 0;
		Integer piBlocksize = 0;
		Integer headerBlockSize = 0;
		Integer piRecordsize = 0;
		Boolean pbEndOfFile = false;
		Boolean pbisFirstBlock = true;
		Boolean footerStatus = false;
		String blockString = null;
		String psRecordContent = "";
		StringReader srTLF = null;
		StringBuffer headerRecord = new StringBuffer();
		String isBlockSizeAvailable = form.getBlockSizeAvailable();
		BufferedReader bufferReader = null;
		boolean isFileDateLogged = false;

		if (isBlockSizeAvailable != null && isBlockSizeAvailable.equals("Y")) {
			headerBlockSize = form.getBlockSize();
		}

		try {
			String headerAvailableCheck = form.getFileHeaderAvailable();
			bufferReader = new BufferedReader(new FileReader(form.getFileLocalPath() + fileName));

			while (!pbEndOfFile) {
				pcData = new char[headerBlockSize]; // Reading each Block Header
				bufferReader.read(pcData, 0, headerBlockSize);

				if(pcData == null || new String(pcData).equals("\u0000\u0000\u0000\u0000\u0000\u0000")){
					pbEndOfFile = true;
					break;
				}
				headerRecord = headerRecord.append(pcData);
				piBlocksize = Integer.parseInt(new String(pcData));
				piOffset = headerBlockSize;

				blockString = bufferReader.readLine();

				if (srTLF != null) {
					srTLF.close();
				}
				srTLF = new StringReader(blockString);

				while (piOffset < piBlocksize) {

					if (!pbisFirstBlock) { // if it is not header block..

						// Read the records upto end of block
						pcData = new char[headerBlockSize]; // Reading each Record Header
						srTLF.read(pcData, 0, headerBlockSize);
						piRecordsize = Integer.parseInt(new String(pcData));
						piOffset += headerBlockSize;

						pcData = new char[piRecordsize - headerBlockSize]; // Reading each Record Content

						srTLF.read(pcData, 0, piRecordsize - headerBlockSize);

						psRecordContent = new String(pcData);
						piOffset += piRecordsize - headerBlockSize;
					}

					if (pbisFirstBlock) {
						// header logic
						if ((headerAvailableCheck != null && !headerAvailableCheck.equals(""))
								&& headerAvailableCheck.equals(ReconConstants.CHECK_FLAG_YES)) {

							Integer headerKeyCount = form.getHeaderKeyCount();

							for (int i = 0; i < headerKeyCount; i++) {
								// Read the records up to end of block
								pcData = new char[headerBlockSize]; // Reading each Record Header
								srTLF.read(pcData, 0, headerBlockSize);

								headerRecord = headerRecord.append(pcData);

								piRecordsize = Integer.parseInt(new String(pcData));
								piOffset += headerBlockSize;
								pcData = new char[piRecordsize - headerBlockSize]; // Reading each Record Content
								srTLF.read(pcData, 0, piRecordsize - headerBlockSize); // Reading each Record Content
								psRecordContent = new String(pcData);
								piOffset += piRecordsize - headerBlockSize;

								headerRecord = headerRecord.append(psRecordContent);
							}

							logger.debug("header data is : " + headerRecord);
							headerValidation.validateHeader(headerRecord.toString(),form,fileName,loopBack);
							
							pbisFirstBlock = false; // need to delete.
						} else {
							pbisFirstBlock = false;
						}
					} else if (form.getFooterAvailable().equals(ReconConstants.CHECK_FLAG_YES)) {
						if (footerValidation.isFooterRecord(psRecordContent, form)) {

							// TODO : Need to do Footer Validation
							footerStatus = footerValidation.checkFooter(psRecordContent, this.counter, form);
							pbEndOfFile = true;
							break;
						} else {
							String tempId_subTempId = findTemplate(psRecordContent, form,"");
							if (tempId_subTempId != null && !(tempId_subTempId.equals(""))) {
								TemplateForm currentTempForm = templateConfigMap.get(tempId_subTempId);
								List<String> drElementValues = performDataElementValidation(psRecordContent, form,
										currentTempForm);
								isFileDateLogged=SplitData(drElementValues, tempId_subTempId, bufferWritermap, fileNameDtls.get(fileName), currentTempForm,loopBack,fileName,isFileDateLogged,readerDao);
							}
						}
					} else {
						String tempId_subTempId = findTemplate(psRecordContent, form,"");
						if (tempId_subTempId != null && !(tempId_subTempId.equals(""))) {
							TemplateForm currentTempForm = templateConfigMap.get(tempId_subTempId);
							List<String> drElementValues = performDataElementValidation(psRecordContent, form,
									currentTempForm);
							isFileDateLogged=SplitData(drElementValues, tempId_subTempId, bufferWritermap, fileNameDtls.get(fileName), currentTempForm,loopBack,fileName,isFileDateLogged,readerDao);
						}
					}
				}// while
			}// while
		} catch (Exception e) {
			logger.error("Exception occured in readVariableBasedFile() : " , e);
			throw new ReconUserDefinedException("Exception Occured while reading VARIABLE DR Formatted File");
		} finally {
			try {
				if (bufferReader != null)
					bufferReader.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing resources : " + e);
			}
		}
		return footerStatus;
	}


	/**Find Template Id and SubTemplate Id by Passing Data Record
	 * @param drLine Data Record
	 * @param inputForm Input file configuration form
	 * @return String tempId_subTempId
	 * @throws ReconUserDefinedException
	 */
	public String findTemplate(String drLine, InputFileConfigurationForm inputForm, String previousParent) throws ReconUserDefinedException{

		HashMap<String,DrIdentificationForm> drIdyMap = null;
		Set<Entry<String,DrIdentificationForm>> DrIdyEntrySet = null;
		DrIdentificationForm drIdyForm = null;
		String tempId_subTempId = "";
		String dataFormat = "";
		int noOfFormat = 0;

		try{
			dataFormat = inputForm.getDataFormat();
			noOfFormat = inputForm.getNumberOfFormat();
			drIdyMap = inputForm.getDrIdentifierDtlsMap();//Get All DR Identification along with template
			DrIdyEntrySet = drIdyMap.entrySet(); //To Pick Dr Idy Form in Template Wise

			if(dataFormat.equalsIgnoreCase("F")  || dataFormat.equals("V") ){
				for(Entry<String,DrIdentificationForm> entry : DrIdyEntrySet){	
					drIdyForm = entry.getValue();
					
					/*					if (noOfFormat == 1) {
						drIdyForm tempId_subTempId = entry.getKey();
						return tempId_subTempId;
					}*/
					 
					if ((noOfFormat == 1) && inputForm.getDrIdentifierAvailableFlag().equals("N")) {// need to put condition for single format having no identification
						tempId_subTempId = entry.getKey();
						return tempId_subTempId;
					} else if ((noOfFormat == 1 && inputForm.getDrIdentifierAvailableFlag().equals("Y"))
							|| (noOfFormat > 1)) {
						// need to put condition for single format having identification
						boolean status = true;
						for(int i = 0; i< drIdyForm.getTemplateId().size(); i++){
							if(status){
								String identifier = drIdyForm.getDrIdentifier().get(i);
								int offset = Integer.parseInt(drIdyForm.getDrOffset().get(i));
								String content = drLine.substring(offset - 1);
								// Added by Mohan Raj.V on 24-03-16 for reading different values in same offset for single template
								if( identifier.contains(",") ) {
									String [] identifierList = identifier.split(",");
									for( int j = 0 ; j < identifierList.length ; j++ ) {
										if( content.startsWith( identifierList[j] ) ) {
											status = true ;
											break;
										} else {
											status = false ;
										}
									}
								} else {
								if (content.startsWith(identifier)) {
									status = true;
								}else{
									status = false;
									}
								}
							}
						}
						if(status){
							tempId_subTempId = entry.getKey();
							return tempId_subTempId;
						}
					}
				}
//				logger.debug("No Template Found For Transaction : "+drLine); commented by Mohan Raj.V for Benchmarking
			} else if (dataFormat.equalsIgnoreCase("K")) {
				for (Entry<String, DrIdentificationForm> entry : DrIdyEntrySet) {
					drIdyForm = entry.getValue();
					for (int i = 0; i < drIdyForm.getTemplateId().size(); i++) {
						String keyIdentifier = drIdyForm.getDrIdentifier().get(i);
						String strIdentifier = drIdyForm.getStringIdentifier().get(i);
						String offsets = drIdyForm.getDrOffset().get(i);

						/* Start new variables Required For KEY IDENTIFIER ALONG WITH && SYMBOL */
						
						String key1 = "";
						String key2 = "";
						String  offset1= "";
						String  offset2 = "";
						String content1 = "";
						String content2 = "";
						
						/* END new variables Required For KEY IDENTIFIER ALONG WITH && SYMBOL */ 
						
						int offset = 0;
						String content = "";

						if((keyIdentifier.contains("&&")) && (offsets.contains("&&"))){ //In case two key values with &&
							String[] keyList = keyIdentifier.split("&&");
							String[] offsetList = offsets.split("&&");
							key1 = keyList[0] ;
							key2 =  keyList[1];
							offset1 = offsetList[0];
							offset2 = offsetList[1];
							try{
								content1 = drLine.substring(Integer.parseInt(offset1)-1);
								content2 = drLine.substring(Integer.parseInt(offset2)-1);
							}catch(Exception e){
								logger.error("Exception occured : "+e);
							}
						}else if((keyIdentifier.contains("||")) && (offsets.contains("||"))){ //In case two key values with ||
							String[] keyList = keyIdentifier.split(Pattern.quote("||"));
							String[] offsetList = offsets.split(Pattern.quote("||"));
							key1 = keyList[0] ;
							key2 =  keyList[1];
							offset1 = offsetList[0];
							offset2 = offsetList[1];
							try{
								content1 = drLine.substring(Integer.parseInt(offset1)-1);
								content2 = drLine.substring(Integer.parseInt(offset2)-1);
							}catch(Exception e){
								logger.error("Exception occured : "+e);
							}
						}
						else{
							 offset = Integer.parseInt(drIdyForm.getDrOffset().get(i));
							 content = "";
							try{
								content = drLine.substring(offset - 1);
							} catch(Exception e){
								logger.error("Exception occured : "+e);
							}
						}
							if (strIdentifier.equalsIgnoreCase("contains") || strIdentifier.equalsIgnoreCase("fixed") || strIdentifier.equalsIgnoreCase("end") || strIdentifier.equalsIgnoreCase("merge") || strIdentifier.equalsIgnoreCase("mergeAndFixed")) { //fixed added by Mohan Raj to read Advisory File 
								if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
									if((keyIdentifier.contains("&&")) && (offsets.contains("&&"))){	
										if(content1.contains(key1) && content2.contains(key2)) {
												tempId_subTempId = entry.getKey();
												if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
													if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
														return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
													} 
												} else {
													return tempId_subTempId+"~"+" ";	
												}
										}
									}else if((keyIdentifier.contains("||")) && (offsets.contains("||"))){	
										if(content1.contains(key1) || content2.contains(key2)) {
											tempId_subTempId = entry.getKey();
											if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
												if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
													return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
												} 
											} else {
												return tempId_subTempId+"~"+" ";	
											}
										}
									}
								}else if (content.contains(keyIdentifier)) {
									tempId_subTempId = entry.getKey();
									if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
										if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
											return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
										} 
									} else {
										return tempId_subTempId+"~"+" ";	
									}
								}
							} else if (strIdentifier.equalsIgnoreCase("none")) {
								if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
									if((keyIdentifier.contains("&&")) && (offsets.contains("&&"))){	
										if(content1.startsWith(key1) && content2.startsWith(key2)) {
												tempId_subTempId = entry.getKey();
												if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
													if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
														return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
													} 
												} else {
													return tempId_subTempId+"~"+" ";	
												}
										}
									}else if((keyIdentifier.contains("||")) && (offsets.contains("||"))){	
										if(content1.startsWith(key1) || content2.startsWith(key2)) {
											tempId_subTempId = entry.getKey();
											if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
												if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
													return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
												} 
											} else {
												return tempId_subTempId+"~"+" ";	
											}
										}
									}
								}else if (content.startsWith(keyIdentifier)) {
									tempId_subTempId = entry.getKey();
									if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
										if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
											return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
										} 
									} else {
										return tempId_subTempId+"~"+" ";	
									}
								}
							} else if(strIdentifier.equalsIgnoreCase("skip")){
								if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
									if((keyIdentifier.contains("&&")) && (offsets.contains("&&"))){	
										if(content1.startsWith(key1) && content2.startsWith(key2)) {
												tempId_subTempId = entry.getKey();
												if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
													if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
														return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
													} 
												} else {
													return tempId_subTempId+"~"+" ";	
												}
										}
									}else if((keyIdentifier.contains("||")) && (offsets.contains("||"))){	
										if(content1.startsWith(key1) || content2.startsWith(key2)) {
											tempId_subTempId = entry.getKey();
											if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
												if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
													return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
												} 
											} else {
												return tempId_subTempId+"~"+" ";	
											}
										}
									}
								}else if (content.startsWith(keyIdentifier)) {
									tempId_subTempId = entry.getKey();
									if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
										if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
											return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
										} 
									} else {
										return tempId_subTempId+"~"+" ";	
									}
								}
							} else if(strIdentifier.equalsIgnoreCase("skipr")){
								if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
									if((keyIdentifier.contains("&&")) && (offsets.contains("&&"))){	
										if(content1.startsWith(key1) && content2.startsWith(key2)) {
												tempId_subTempId = entry.getKey();
												if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
													if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
														return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
													} 
												} else {
													return tempId_subTempId+"~"+" ";	
												}
										}
									}else if((keyIdentifier.contains("||")) && (offsets.contains("||"))){	
										if(content1.startsWith(key1) || content2.startsWith(key2)) {
											tempId_subTempId = entry.getKey();
											if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
												if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
													return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
												} 
											} else {
												return tempId_subTempId+"~"+" ";	
											}
										}
									}
								}else if (content.startsWith(keyIdentifier)) {
									tempId_subTempId = entry.getKey();
									if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
										if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
											return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
										} 
									} else {
										return tempId_subTempId+"~"+" ";	
									}
								}
								// below containsnext logic is added by Mohan Raj.V to check for contains and need to read next line on 30-03-18
							}else if (strIdentifier.equalsIgnoreCase("next") || strIdentifier.equalsIgnoreCase("next_2") || strIdentifier.equalsIgnoreCase("next_5") || strIdentifier.equalsIgnoreCase("containsNext")  ) { // Added by Mohan Raj.V on 16/03/16 for reading next two line
								if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
									if((keyIdentifier.contains("&&")) && (offsets.contains("&&"))){	
										if(content1.startsWith(key1) && content2.startsWith(key2)) {
												tempId_subTempId = entry.getKey();
												if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
													if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
														return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
													} 
												} else {
													return tempId_subTempId+"~"+" ";	
												}
										}
									}else if((keyIdentifier.contains("||")) && (offsets.contains("||"))){	
										if(content1.startsWith(key1) || content2.startsWith(key2)) {
											tempId_subTempId = entry.getKey();
											if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
												if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
													return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
												} 
											} else {
												return tempId_subTempId+"~"+" ";	
											}
										}
									}
								}else if (content.startsWith(keyIdentifier)) {
									tempId_subTempId = entry.getKey();
									if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
										if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
											return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
										} 
									} else {
										return tempId_subTempId+"~"+" ";	
									}
								} else if( strIdentifier.equalsIgnoreCase("containsNext") ){ 
									if( content.trim().contains(keyIdentifier.trim()) ){
										tempId_subTempId = entry.getKey();
										if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
											if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
												return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
											} 
										} else {
											return tempId_subTempId+"~"+" ";	
										}
									}
								}
							}/* else if( strIdentifier.equalsIgnoreCase("containsNext") ){ 
								if( content.contains(keyIdentifier) ){
									tempId_subTempId = entry.getKey();
									if( "C".equalsIgnoreCase( entry.getValue().getParentChildIndicator().get(i) ) ){
										if( previousParent .equalsIgnoreCase( entry.getValue().getParent().get(i) ) ){
											return tempId_subTempId+"~"+ entry.getValue().getParent().get(i) ;
										} 
									} else {
										return tempId_subTempId+"~"+" ";	
									}
								}
							}*/
						}
					}
//					logger.debug("No Template Found For Transaction : " + drLine); commented by Mohan Raj.V for benchmarking
				}
			} catch (Exception e) {
				logger.error("Exception Occured while Finding the Template By Passing Data Record : " + e);
				throw new ReconUserDefinedException("Exception Occured while Finding the Template By Passing Data Record");
			}
			return tempId_subTempId;
		}


		/**Return DR Configuration by passing template and subtemplate ID
		 * @param drLine Data Record
		 * @param drIdyMap Map For DrIdentificationForm
		 * @param tempId_subTempId Template and Sub Template Id
		 * @return Map<String,BufferedWriter>
		 * @throws ReconUserDefinedException
		 */
		public KeyBasedDataRecord DRInfoForKeyBased(String drLine, Map<String,DrIdentificationForm> drIdyMap,String tempId_subTempId)throws ReconUserDefinedException{

			Set<Entry<String,DrIdentificationForm>> DrIdyEntrySet = null;
			DrIdentificationForm drIdyForm =null;
			KeyBasedDataRecord keyBasedDr = null;
			try {

				DrIdyEntrySet = drIdyMap.entrySet(); // To Pick Dr Idy Form in Template Wise

				for (Entry<String, DrIdentificationForm> entry : DrIdyEntrySet) {
					drIdyForm = entry.getValue();
					tempId_subTempId = entry.getKey();

					for (int j = 0; j < drIdyForm.getTemplateId().size(); j++) {

						String key = drIdyForm.getDrIdentifier().get(j);
						String offsets = drIdyForm.getDrOffset().get(j);
						String identifier = drIdyForm.getStringIdentifier().get(j);
						String content = "";
						
						/* Start new variables Required For KEY IDENTIFIER ALONG WITH && SYMBOL */
						String key1 = "";
						String key2 = "";
						String  offset1= "";
						String  offset2 = "";
						String content1 = "";
						String content2 = "";
						
						/* END new variables Required For KEY IDENTIFIER ALONG WITH && SYMBOL */ 
						
						int offset = 0;
						

						if((key.contains("&&")) && (offsets.contains("&&"))){ //In case two key values with &&
							String[] keyList = key.split("&&");
							String[] offsetList = offsets.split("&&");
							key1 = keyList[0] ;
							key2 =  keyList[1];
							offset1 = offsetList[0];
							offset2 = offsetList[1];
							try{
								content1 = drLine.substring(Integer.parseInt(offset1)-1);
								content2 = drLine.substring(Integer.parseInt(offset2)-1);
							}catch(Exception e){
								logger.error("Exception occured : "+e);
							}
						}else if((key.contains("||")) && (offsets.contains("||"))){ //In case two key values with ||
							String[] keyList = key.split(Pattern.quote("||"));
							String[] offsetList = offsets.split(Pattern.quote("||"));
							key1 = keyList[0] ;
							key2 =  keyList[1];
							offset1 = offsetList[0];
							offset2 = offsetList[1];
							try{
								content1 = drLine.substring(Integer.parseInt(offset1)-1);
								content2 = drLine.substring(Integer.parseInt(offset2)-1);
							}catch(Exception e){
								logger.error("Exception occured : "+e);
							}
						}else{
							 offset = Integer.parseInt(drIdyForm.getDrOffset().get(j));
							try{
								content = drLine.substring(offset-1);
							} catch(Exception e){
								logger.error("Exception while sub string : "+e);
							}
						}
	
						if (identifier.equalsIgnoreCase("none")) {
							boolean status = false;
							if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
								if((key.contains("&&")) && (offsets.contains("&&"))){	
									if(content1.startsWith(key1) && content2.startsWith(key2)) {
										status = true;
									}
								}else if((key.contains("||")) && (offsets.contains("||"))){	
									if(content1.startsWith(key1) || content2.startsWith(key2)) {
										status = true;
									}
								}
							}else if (content.startsWith(key)) {
								status = true;
							}
							if(status){
								keyBasedDr = new KeyBasedDataRecord();
								keyBasedDr.setTemp_subTempId(tempId_subTempId);
								keyBasedDr.setKey(key);
								keyBasedDr.setOffSet(offset);
								keyBasedDr.setParentChildIndicator(drIdyForm.getParentChildIndicator().get(j));
								keyBasedDr.setParentKey(drIdyForm.getParent().get(j));
								keyBasedDr.setColumnIds(drIdyForm.getColumns().get(j));
								keyBasedDr.setStrIdentifier(drIdyForm.getStringIdentifier().get(j));
								return keyBasedDr;
							}
						} else if (identifier.equalsIgnoreCase("contains") || identifier.equalsIgnoreCase("fixed") || identifier.equalsIgnoreCase("end") ||  identifier.equalsIgnoreCase("merge") || identifier.equalsIgnoreCase("mergeAndFixed") ) { // added by Mohan Raj.V to read Advisory File
							boolean status = false;
							if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
								if((key.contains("&&")) && (offsets.contains("&&"))){	
									if(content1.contains(key1) && content2.contains(key2)) {
										status = true;
									}
								}else if((key.contains("||")) && (offsets.contains("||"))){	
									if(content1.contains(key1) || content2.contains(key2)) {
										status = true;
									}
								}
							}else if (content.contains(key)) {
								status = true;
							}
							if(status){
								keyBasedDr = new KeyBasedDataRecord();
								keyBasedDr.setTemp_subTempId(tempId_subTempId);
								keyBasedDr.setKey(key);
								keyBasedDr.setOffSet(offset);
								keyBasedDr.setParentChildIndicator(drIdyForm.getParentChildIndicator().get(j));
								keyBasedDr.setParentKey(drIdyForm.getParent().get(j));
								keyBasedDr.setColumnIds(drIdyForm.getColumns().get(j));
								keyBasedDr.setStrIdentifier(drIdyForm.getStringIdentifier().get(j));
								return keyBasedDr;
							}
						} else if (identifier.equalsIgnoreCase("skip") || identifier.equalsIgnoreCase("skipr")) {
							boolean status = false;
							if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
								if((key.contains("&&")) && (offsets.contains("&&"))){	
									if(content1.startsWith(key1) && content2.startsWith(key2)) {
										status = true;
									}
								}else if((key.contains("||")) && (offsets.contains("||"))){	
									if(content1.startsWith(key1) || content2.startsWith(key2)) {
										status = true;
									}
								}
							}else if (content.startsWith(key)) {
								status = true;
							}
							if(status){
								keyBasedDr = new KeyBasedDataRecord();
								keyBasedDr.setTemp_subTempId(tempId_subTempId);
								keyBasedDr.setKey(key);
								keyBasedDr.setOffSet(offset);
								keyBasedDr.setParentChildIndicator(drIdyForm.getParentChildIndicator().get(j));
								keyBasedDr.setParentKey(drIdyForm.getParent().get(j));
								keyBasedDr.setColumnIds(drIdyForm.getColumns().get(j));
								keyBasedDr.setStrIdentifier(drIdyForm.getStringIdentifier().get(j));
								return keyBasedDr;
							}
						}else if (identifier.equalsIgnoreCase("next") || identifier.equalsIgnoreCase("next_2") || identifier.equalsIgnoreCase("next_5") || identifier.equalsIgnoreCase("containsNext")) { // Added by Mohan Raj.V on 16/03/16 for reading next two line
							boolean status = false;
							if (!"".equals(content1) && !"".equals(content2) && !"".equals(key1) && !"".equals(key2)){
								if((key.contains("&&")) && (offsets.contains("&&"))){	
									if(content1.startsWith(key1) && content2.startsWith(key2)) {
										status = true;
									}
								}else if((key.contains("||")) && (offsets.contains("||"))){	
									if(content1.startsWith(key1) || content2.startsWith(key2)) {
										status = true;
									}
								}
							}else if (content.startsWith(key)) {
								status = true;
							} else if( identifier.equalsIgnoreCase("containsNext") ){ // modified by Mohan Raj.V on 30-03-18
								if( content.trim().contains(key.trim()) ){
									status = true;
								}
								}
							if(status){
								keyBasedDr = new KeyBasedDataRecord();
								keyBasedDr.setTemp_subTempId(tempId_subTempId);
								keyBasedDr.setKey(key);
								keyBasedDr.setOffSet(offset);
								keyBasedDr.setParentChildIndicator(drIdyForm.getParentChildIndicator().get(j));
								keyBasedDr.setParentKey(drIdyForm.getParent().get(j));
								keyBasedDr.setColumnIds(drIdyForm.getColumns().get(j));
								keyBasedDr.setStrIdentifier(drIdyForm.getStringIdentifier().get(j));
								return keyBasedDr;
							}
						} 
					}
				}
			} catch (Exception e) {
				logger.error("Exception Occured while getting Specific DR Configuration From Method DRInfoForKeyBased() :"
						+ e);
				throw new ReconUserDefinedException(
						"Exception Occured while getting Specific DR Configuration From Method DRInfoForKeyBased()");
			} finally {
				DrIdyEntrySet = null;
				drIdyForm = null;
			}
			return keyBasedDr;
		}

	/** Method to read Data Element Values For KEY BASEd DR Format
	 * @param drLine Data Record
	 * @param inputFileForm Input File Configuration Form
	 * @param elementForm Template Configuration Form
	 * @param tempId_subTempId Template Id and Sub Template id
	 * @param columnIds Readable column Position in a line
	 * @param elementValues  Element values
	 * @param tranCodeMap Map for Code with Transaction description
	 * @return List<Object>
	 * @throws ReconUserDefinedException
	 */
	public List<Object> performKeyBasedDataElementValidation(String drLine, String fileName, InputFileConfigurationForm inputFileForm,
			TemplateForm elementForm, String tempId_subTempId, String columnIds, List<String> elementValues,
			Map<String, String> tranCodeMap) throws ReconUserDefinedException {

		List<Object> temp_SubTempId_ElementValues = null;
		List<Integer> columnPosition = null;
		List<String> columnName = null;
		List<Integer> columnType = null;
		List<Integer> columnFormat = null;
		List<String> columnFromPos = null;
		List<String> columnToPos = null;
		List<Integer> columnKeyIdentity = null;
		List<String> columnOrOffset = null;
		List<Integer> columnID = null;
		List<Integer> columnLength = null;
		List<String> columnFormatDesc = null;
		List<String> columnMandatoryFlag = null;		
		String[] readColumns = null;
		String data = "";
		int calculatedFromPos[] = null;
		int controlFlagCount = 0;	//Footer Control Tag Count child table
		
		String cardNumber="",colName="";
		
		Long manin_temp_id = elementForm.getTemplateId();
//		Added By nancy to send tempalate id with Sub template id :starts
		int sub_temp_id = elementForm.getSubTemplateId();
		String temp_id = manin_temp_id+"-"+sub_temp_id;
		
		boolean countStatus = true;
		String fileType = "";
		int columnId = 0;
		String mandatoryFlagCatch = "";

		try {
			fileType = inputFileForm.getFileType();

			if(columnIds != null && !columnIds.equals("")){
				
				columnID = elementForm.getColumnID();
				columnName = elementForm.getColumnName();
				columnFormatDesc = elementForm.getColumnFormatDesc();
				columnFromPos = elementForm.getColumnFromPos();
				columnToPos = elementForm.getColumnToPos();
				columnPosition = elementForm.getColumnPosition();
				columnType = elementForm.getColumnType();
				columnFormat  = elementForm.getColumnFormat();
				columnMandatoryFlag = elementForm.getColumnMandatoryFlag();
				columnLength = elementForm.getColumnLength();
				columnKeyIdentity = elementForm.getColumnKeyIdentity();
				columnOrOffset = elementForm.getColumnOrOffset();
				
				int colIndex = 0; // Increment variable for Readable column index from method input parameter columnIds
				int fromIndex = 0; // Temporary variable To store from index for every element
				int toIndex = 0; // Temporary variable To store to index for every element

				readColumns = columnIds.split(",");
				calculatedFromPos = new int[readColumns.length];
				Map<Integer,Integer> toPosMap = new HashMap<Integer, Integer>(); // Using By FROM OFFSET SCENARIO

				// Initially Fill the list with empty values for a transaction
				if(elementValues != null && elementValues.size() == 0){
					for(int i = 0; i< columnID.size(); i++) {
						elementValues.add("");
					}
				}
				 
				//Iterate Readable Column Position from list of columns seperated by ','
				for(String columnid : readColumns){
						
					//Iterate Stored columns in DB to find out readable column
					for(int i = 0; i < columnID.size(); i++) {
						mandatoryFlagCatch = columnMandatoryFlag.get(i).toString(); 
						if( columnid != null  && !(columnid.equals("")) && columnPosition.get(i) == Integer.parseInt(columnid)){ // If column match found
						
							colName = columnName.get(i);
						//Changed by vinoth on 20-06-16 for KeyIdenifier
							switch (columnKeyIdentity.get(i)) {
							case 1: // From Offset
								if(colIndex != 0){ // FROM OFFSET SHOULD NOT BE CONFIGURED FOR FIRST COLUMN
									int colPos = Integer.parseInt(columnOrOffset.get(i)); // Get Previously Configured Column Position
									
									if(columnFromPos.get(i) != null && !(columnFromPos.get(i).equals(""))){
										fromIndex = drLine.indexOf(columnFromPos.get(i),toPosMap.get(colPos) -1); //-1 added by Mohan need to test properly 
										if(fromIndex != -1){
											if(columnFromPos.get(i).length() == 1 || columnFromPos.get(i).length() > 1){
											 fromIndex = fromIndex+columnFromPos.get(i).length();
											}
										}
									}else{
										fromIndex = toPosMap.get(colPos);
									}
								}
								break;
							case 2: //IndexOf
								if(colIndex == 0){ // First Column Is configured as Index Of then take first occurrence of (INDEX OF DATA eg., :CARD)

									fromIndex = drLine.indexOf(columnOrOffset.get(i));

								}else if(colIndex != 0 && calculatedFromPos[colIndex]!= -1 && calculatedFromPos[colIndex] != 0){ //  Except First column, find Proper position of (INDEX OF DATA  eg., :CARD ) by passing start Index

									fromIndex = drLine.indexOf(columnOrOffset.get(i),calculatedFromPos[colIndex]); // note to modifiy as calculatedFromPos[colIndex] -1
								}
								if(fromIndex != -1){
									if( columnFromPos.get(i).contains("+")){
										String fromValue =  columnFromPos.get(i).substring( columnFromPos.get(i).indexOf("+")+1); // Take Number To Add it in From Index
										if(fromValue.matches("\\d+")){
											fromIndex = fromIndex + Integer.parseInt(fromValue);
										}
									}else if(columnFromPos.get(i).contains("-")){
										String fromValue = columnFromPos.get(i).substring(columnFromPos.get(i).indexOf("-")+1);	// Take Number To Subtract it in From Index
										if (fromValue.matches("\\d+")) {
											fromIndex = fromIndex - Integer.parseInt(fromValue);
										}
									} /*else {
										if (columnFromPos.get(i).matches("\\d+")) {
											fromIndex = Integer.parseInt(columnFromPos.get(i));
										}
									}*/
								}
								break;
							case 3: //ClientSpecific
								data = "";
								break;
							case 4: //None
								if (columnFromPos.get(i).matches("\\d+")) {									
								fromIndex = Integer.parseInt(columnFromPos.get(i)) - 1;
								}
								break;
							case 5: //TranCode
									String colId = columnOrOffset.get(i);
									String codeDesc = elementValues.get(Integer.parseInt(colId)-1);// GET DESCRIPTION By Passing COLUMN ID
									data = tranCodeMap.get(codeDesc);// Get PROPER CODE STORED AGAINST THIS DESCRIPTION
									if(data == null)
										throw new ReconUserDefinedException("TranCode Not Found in DB For DESCRIPTION :"+codeDesc);								
								break;
							case 6: //constant
							case 7: //TODATE
								continue;
							case 8: break;//Decode
							case 9: break;//Tagof
							case 10: //Encrypt	 						
								String encryptedData = SecurityUtils.encryptText(cardNumber.trim().getBytes(), inputFileForm.getInstitutionCode(),inputFileForm.getKeystorePassword2(),inputFileForm.getHexData());							
								elementValues.add(i,new String(encryptedData));							
								continue;
							
							case 12: //Hash
								elementValues.add(i,SecurityUtils.hashingSHA256(cardNumber.trim()));
																
								continue;
							case 13: //Substring
								if (!"FILE_ID".equals(columnName.get(i))) {
									//columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));								
									data = drLine.substring(Integer.parseInt(columnFromPos.get(i)), Integer.parseInt(columnToPos.get(i)));
									//resultElements.add(i,data);
								}else{
									data=fileName.substring(0,fileName.lastIndexOf("."));
								}
								break;
							case 14: //For skip
								elementValues.add(i,"");
								continue;
							case 15: //Expr
								if (columnFromPos.get(i).matches("\\d+")) {									
									fromIndex = Integer.parseInt(columnFromPos.get(i)) - 1;
									}
							default:
								break;
							}
						//	Ends vinoth..
						
							
							
							if(columnKeyIdentity.get(i) != 5 && columnKeyIdentity.get(i) != 3 && columnKeyIdentity.get(i) != 13 ){ // column key identity is NOT TRANCODE then read data from transaction by using TO POSITION
								if(fromIndex != -1){
									if(columnToPos.get(i) == null || columnToPos.get(i).equals("")){ // TO POSITION CONFIGURED EMPTY THEN READ TILL EOL
										data = drLine.substring(fromIndex);
										toIndex = 0;
									}else if(columnToPos.get(i).matches("\\d+")){ // TO POSITION CONFIGURED NUMBER THEN USE TOPOSITION IN SUBSTRING METHOD
										data = drLine.substring(fromIndex,Integer.parseInt(columnToPos.get(i)));
										toIndex = Integer.parseInt(columnToPos.get(i));
									}else{// // TO POSITION CONFIGURED ALPHANUMERIC THEN FIND ITS INDEX AND READ TILL THAT INDEX

										toIndex =  drLine.indexOf(columnToPos.get(i),fromIndex);
										if(toIndex != -1)
											data = drLine.substring(fromIndex,toIndex);
										toIndex = toIndex + columnToPos.get(i).length();
									}
								} else{
									data = "";
								}
							}
							
							/************* START THE BLOCK TO MAINTAIN FROM AND TO INDEXES ***********/
							calculatedFromPos[colIndex] = fromIndex; // Store Calculated From Index
							toPosMap.put(Integer.parseInt(columnid),toIndex); // Store Calculated To Index along with Column Id

							if(colIndex != (readColumns.length -1)) // IF ITS NOT A LAST ELEMENT THEN STORE NEXT ELEMENT'S FROM POSITION USING THIS TO INDEX VALUE 
								calculatedFromPos[colIndex + 1] = toIndex;
							
							/************* END THE BLOCK TO MAINTAIN FROM AND TO INDEXES ***********/
							//Added by Mohan Raj.V on 29-03-2016 to save terminal id for admin EJ Transaction
							if( "EJ".equalsIgnoreCase( elementForm.getTemplateTypeDesc() ) ) {
								if( "TERM_ID".equalsIgnoreCase( columnName.get(i) ) ) {
									terminalId = data.trim();
								}
							}
							
							if(ReconConstants.CARDNUMBER.equals(columnName.get(i))){
								cardNumber=data;
								data=StringUtils.maskNumber(data.trim()).trim();
							}else if("TRAN_AMOUNT".equals(columnName.get(i))){
								data=data.replace(",", ".");
							}
														
							
							String mandatoryFlag = columnMandatoryFlag.get(i).toString(); 
							
							data=doDataValidation(data.trim(), mandatoryFlag, elementForm, i);

											
							elementValues.remove(i);
							elementValues.add(i,data.trim());

							//Logic to calculate Footer control tag values

							controlFlagCount = inputFileForm.getControlTagCount() != null ? inputFileForm.getControlTagCount() : 0;
							if(controlFlagCount>0){
								String ctrlType = "";
								int fieldId = 0;
								int chkFieldId = 0;
								String chkConstant = "";
								String checkValue = "";
								boolean rowIdentification = true;
								if(mandatoryFlag.equals("Y")){
									
									Map<String, List<FooterConfiguration>> footerConfiguration = inputFileForm.getFooterConfig();
									List<FooterConfiguration> footerConfig = footerConfiguration.get(temp_id);

									for (int j = 0; j < controlFlagCount; j++) {
										chkFieldId = footerConfig.get(j).getControlCheckField() != null ? footerConfig.get(j).getControlCheckField() : 0;
										chkConstant = footerConfig.get(j).getControlCheckConstant() != null ? footerConfig.get(j).getControlCheckConstant() : "";

										if (chkFieldId > 0) {
											for (int k = 0; k < columnID.size(); k++) {
												int id = columnID.get(k) != null ? columnID.get(k) : 0;

												if (id == chkFieldId && elementValues.size() >= id && elementValues.get(id-1)!=null) {
													/*if(columnFromPos.get(k).matches("\\d+") && columnToPos.get(k).matches("\\d+")){
														checkValue = drLine.substring(Integer.parseInt(columnFromPos.get(k))-1, Integer.parseInt( columnToPos.get(k))).trim();
														break;
													}else{

													}	*/
													
													checkValue = elementValues.get(id-1);
												}
											}
											/*if (checkValue != null && !checkValue.equals("")) {
												if (!chkConstant.equals(""))
													if (!checkValue.equalsIgnoreCase(chkConstant))
														rowIdentification = false;
													else
														rowIdentification = true;
											} else {
												rowIdentification = true;
											}*/
										}
										if(rowIdentification){

											ctrlType = footerConfig.get(j).getControlType() != null ? footerConfig.get(j).getControlType() : "";
											if(ctrlType.equalsIgnoreCase("CNT") && countStatus == true){

												int rowCount = 0;
												if(calculatedValues.size() > 0){
													rowCount=calculatedValues.get(j)!=null?Integer.parseInt(calculatedValues.get(j).toString()):0;
													calculatedValues.remove(j);	 
												}
												else{
													rowCount = 0;
												}
												rowCount++;
												calculatedValues.add(j,rowCount);
												countStatus = false;
												break;

											}else if(ctrlType.equalsIgnoreCase("SUM")){

												fieldId = footerConfig.get(j).getControlDataRecordField() != null ? footerConfig.get(j).getControlDataRecordField() : 0;

												Integer fId = Integer.parseInt(columnID.get(i).toString());
												if(fId == fieldId){
													//logger.debug("field identified for sum");
													double sumValue = 0.0;
													if(calculatedValues.size()>0){
														sumValue = calculatedValues.get(j)!=null?Double.parseDouble(calculatedValues.get(j).toString()):0.0;
														calculatedValues.remove(j);
													}else
														sumValue = 0.0;

													sumValue = sumValue + Double.parseDouble(data.replace(",", "."));
												//	System.out.println("SUM VALUE : "+sumValue);
													calculatedValues.add(j,sumValue);
													break;
												}
											}
										}
									}
								} else {
									logger.error("Control Flag Element  Should be the configured as Mandatory!");
									throw new ReconUserDefinedException(
											"Control Flag Element  Should be the configured as Mandatory!");
								}
							}
							data="";//Added by Archana.J to empty the data 
							colIndex++; 
							break;
						}
					}//inner for to get db element configuration

				}//outer for to get readable column
				temp_SubTempId_ElementValues = new ArrayList<Object>();
				temp_SubTempId_ElementValues.add(tempId_subTempId);
				temp_SubTempId_ElementValues.add(elementValues);
			}

		} catch (IndexOutOfBoundsException error) { // modified by Mohan Raj.V to allow even though index out of bound exception occured while reading ej for non mandatory fields
	        logger.error("index out of bound exception in line "+drLine+" - "+ error);
	        
	        if( "M".equals( mandatoryFlagCatch ) || "MD".equals( mandatoryFlagCatch ) ){
	        	throw new ReconUserDefinedException("ReconUserDefinedException |  InputfileConfigReader  | "+colName+"  |  " +data+ " | " +error.getMessage());
	        }
	    }catch(ReconUserDefinedException e) {
			logger.error("ReconUserDefinedException While Performing Data Element Validation:  "+drLine , e );
			throw new ReconUserDefinedException("ReconUserDefinedException |  InputfileConfigReader  | "+colName+"  |  " +data+ " | " +e.getMessage());
		} catch(Exception e) {
			logger.error("Exception While Performing Data Element Validation for a line : "+drLine+" "+e);
			throw new ReconUserDefinedException("Exception |  InputfileConfigReader  | "+colName+"  |  " +data+ " | " + e.getMessage());
		}finally{
			columnPosition = null;
			columnName = null;
			columnType = null;
			columnFormat = null;
			columnFromPos = null;
			columnToPos = null;
			columnKeyIdentity = null;
			columnOrOffset = null;
			columnID = null;
			columnLength = null;
			columnFormatDesc = null;
			columnMandatoryFlag = null;			
			cardNumber=null;
		}
		return temp_SubTempId_ElementValues;
	}


	/**
	 * @param drLine Data Record
	 * @param inputFileForm Input File Configuration Form
	 * @param elementForm Template Configuration Form
	 * @throws ReconUserDefinedException
	 */
	public List<String> performDataElementValidation(String drLine, InputFileConfigurationForm inputFileForm,
			TemplateForm elementForm) throws ReconUserDefinedException {

		List<String> columnName = null;
		List<Integer> columnType = null;
		List<Integer> columnFormat = null;
		List<String> columnFromPos = null;
		List<String> columnToPos = null;
		List<Integer> columnPosition = null;
		List<Integer> columnID = null;
		List<Integer> columnLength = null;
		List<String> columnFormatDesc = null;
		List<String> columnMandatoryFlag = null;
		List<String> al = null;
		List<Integer> keyIdentifier = null;
		List<String> columnOrOffset = null;
		

		List<String> resultElements = new ArrayList<String>();
		

		int controlFlagCount = 0;	//Footer Control Tag Count child table
		String data = "";
		String  fileType= "";
		String mandatoryFlag = "";
		
		String panNumber="",colName="";
		String encryptedData="";
		int columnId=0;							
		int formPosition=0;						
		int toPosition=0;	

		try {

			/*logger.debug("controlType:"+controlType+"  controlDataFromPosition : "+controlDataFromPosition+"  " +
					"controlDataToPosition:"+controlDataToPosition+"  controlDataColumnPosition:"+controlDataColumnPosition+"  controlDataRecordField:"+controlDataRecordField+"" +
					" controlCheckField :"+controlCheckField+" controlCheckConstant:"+controlCheckConstant);
			 */
			
			columnID = elementForm.getColumnID();
			columnName = elementForm.getColumnName();
			columnFormatDesc = elementForm.getColumnFormatDesc();
			columnFromPos = elementForm.getColumnFromPos();
			columnToPos = elementForm.getColumnToPos();	
			columnPosition = elementForm.getColumnPosition();
			columnType = elementForm.getColumnType();
			columnFormat  = elementForm.getColumnFormat();
			columnMandatoryFlag = elementForm.getColumnMandatoryFlag();
			columnLength = elementForm.getColumnLength();
			keyIdentifier = elementForm.getColumnKeyIdentity();
			columnOrOffset = elementForm.getColumnOrOffset();
			Long manin_temp_id = elementForm.getTemplateId();
//			Added By nancy to send tempalate id with Sub template id :starts
			int sub_temp_id = elementForm.getSubTemplateId();
			String temp_id = manin_temp_id+"-"+sub_temp_id;
//			Added By nancy to send tempalate id with Sub template id :ends
			
			fileType = inputFileForm.getFileType();
			boolean countStatus = true;
			int fromIndex = 0;
			
		/*	if(fileType != null && fileType.equals("D")){
				al = Arrays.asList(drLine.split(Pattern.quote(inputFileForm.getDelimiter()), -1)); //argument -1 added by Dharun for handling last column empty values
			}*/
			
			if(fileType != null && fileType.equals("D")){
				if(inputFileForm.getDelimiter().equals("\\t")){
					al = Arrays.asList(drLine.split(Pattern.quote("\t"),-1));
				}
				else{
					al = Arrays.asList(drLine.split(Pattern.quote(inputFileForm.getDelimiter()), -1)); //argument -1 added by Dharun for handling last column empty values
				}
				
			}

			/*			logger.debug("columnID:"+columnID+" columnName:"+columnName+" columnTypeDesc:"+columnTypeDesc+
					"columnFormatDesc:"+columnFormatDesc+" columnFromPos:"+columnFromPos+" columnToPos:"+columnToPos+
					" columnPosition: "+columnPosition+" columnType:"+columnType+" columnFormat:"+columnFormat+
					" columnMandatoryFlag:"+columnMandatoryFlag+" columnLength:"+columnLength);*/

			if(columnID != null ) {

				for(int i=0; i< columnID.size(); i++) {

					colName = columnName.get(i);
					//Changed by vinoth on 20-06-16 for KeyIdentifier
									
						switch (keyIdentifier.get(i)) {
						case 2: //Index of 
								
								if(fileType.equals("D")) {
							    data = al.get(i);
								fromIndex = data.indexOf(columnOrOffset.get(i));
								
								
								if( columnFromPos.get(i).contains("+")){
									String fromValue =  columnFromPos.get(i).substring( columnFromPos.get(i).indexOf("+")+1); // Take Number To Add it in From Index
									if(fromValue.matches("\\d+")){
										fromIndex = fromIndex + Integer.parseInt(fromValue);
									}
								}else if(columnFromPos.get(i).contains("-")){
									String fromValue = columnFromPos.get(i).substring(columnFromPos.get(i).indexOf("-")+1);	// Take Number To Subtract it in From Index
									if (fromValue.matches("\\d+")) {
										fromIndex = fromIndex - Integer.parseInt(fromValue);
									}
								} 
								
								if(columnToPos.get(i) == null || "".equals(columnToPos.get(i)))
									data = data.substring(fromIndex);
								else 
									data = data.substring(fromIndex, fromIndex+Integer.parseInt(columnToPos.get(i)));
								
								}
								break;
						case 4: break;
						case 6:
						case 7: continue;
						case 10: //Encrypt
							if (fileType != null && fileType.equals("D")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));
								panNumber = al.get(columnId - 1);
							} else if (fileType != null && fileType.equals("F")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));							
								formPosition=Integer.parseInt(columnFromPos.get(columnId-1));						
								toPosition=Integer.parseInt(columnToPos.get(columnId-1));													
								panNumber=drLine.substring(formPosition-1,toPosition);
							}
							encryptedData = SecurityUtils.encryptText(panNumber.trim().getBytes(), inputFileForm.getInstitutionCode(),inputFileForm.getKeystorePassword2(),inputFileForm.getHexData());																
							resultElements.add(i,new String(encryptedData));					
							continue;
						case 11: //Mask
							panNumber = drLine.substring(Integer.parseInt(columnFromPos.get(i))-1, Integer.parseInt(columnToPos.get(i))).trim();
							resultElements.add(i,StringUtils.maskNumber(panNumber.trim()).trim());
							continue;
						case 12: //Hash
							if (fileType != null && fileType.equals("D")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));
								panNumber = al.get(columnId - 1);
							} else if (fileType != null && fileType.equals("F")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));							
								formPosition=Integer.parseInt(columnFromPos.get(columnId-1));							
								toPosition=Integer.parseInt(columnToPos.get(columnId-1));							
								panNumber=drLine.substring(formPosition-1,toPosition);	
							}
							resultElements.add(i,SecurityUtils.hashingSHA256(panNumber.trim()));
							continue;
						case 13: //Substring
							if (fileType != null && fileType.equals("D")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));								
								data = al.get(columnId - 1).substring(Integer.parseInt(columnFromPos.get(i)), Integer.parseInt(columnToPos.get(i)));
								resultElements.add(i,data);
							} 
							continue;
						case 14: //For skip Added by sushmita to avoid reading of unwanted data
							resultElements.add(i,"");
							continue;						
						case 16: //For UpperCase
							if (fileType != null && fileType.equals("D")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));								
								data = al.get(columnId - 1)!=null ? al.get(columnId - 1).toUpperCase().trim():" ";
							}  else if (fileType != null && fileType.equals("F")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));							
								formPosition=Integer.parseInt(columnFromPos.get(columnId-1));							
								toPosition=Integer.parseInt(columnToPos.get(columnId-1));							
								data=drLine.substring(formPosition-1,toPosition).trim()!=null?drLine.substring(formPosition-1,toPosition).toUpperCase().trim():" ";
							}
							mandatoryFlag = columnMandatoryFlag.get(i).toString();
							if(mandatoryFlag.contains("M"))
								data=doDataValidation(data, mandatoryFlag, elementForm, i);//Data Validation done for checking mandatory fields and jumping to for loop directly
							resultElements.add(i,data);//Adding data to resultElements
							continue;
						case 17: //For LowerCase
							if (fileType != null && fileType.equals("D")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));								
								data = al.get(columnId - 1)!=null ? al.get(columnId - 1).toLowerCase().trim():" ";
							}  else if (fileType != null && fileType.equals("F")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));							
								formPosition=Integer.parseInt(columnFromPos.get(columnId-1));							
								toPosition=Integer.parseInt(columnToPos.get(columnId-1));							
								data=drLine.substring(formPosition-1,toPosition).trim()!=null?drLine.substring(formPosition-1,toPosition).toLowerCase().trim():" ";
							}
							mandatoryFlag = columnMandatoryFlag.get(i).toString();
							if(mandatoryFlag.contains("M"))
								data=doDataValidation(data, mandatoryFlag, elementForm, i);//Data Validation done for checking mandatory fields and jumping to for loop directly
							resultElements.add(i,data);//Adding data to resultElements
							continue;
						case 18: //For Copy To - Added By Ankush Saini on 22-02-2018
							if (fileType != null && fileType.equals("D")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));								
								data = al.get(columnId - 1)!=null ? al.get(columnId - 1).trim():" ";
							}  else if (fileType != null && fileType.equals("F")) {
								columnId=Integer.parseInt(elementForm.getColumnOrOffset().get(i));							
								formPosition=Integer.parseInt(columnFromPos.get(columnId-1));							
								toPosition=Integer.parseInt(columnToPos.get(columnId-1));							
								data=drLine.substring(formPosition-1,toPosition).trim()!=null?drLine.substring(formPosition-1,toPosition).trim():" ";
							}
							mandatoryFlag = columnMandatoryFlag.get(i).toString();
							if(mandatoryFlag.contains("M"))
								data=doDataValidation(data, mandatoryFlag, elementForm, i);//Data Validation done for checking mandatory fields and jumping to for loop directly
							resultElements.add(i,data);//Adding data to resultElements
							continue;
						default:
							break;
						}					

						//	Changes completed..
					
					if (fileType != null && fileType.equals("D") && keyIdentifier.get(i) != 13 && keyIdentifier.get(i) != 2 ) {
						
						mandatoryFlag = columnMandatoryFlag.get(i).toString();
						
						//Added By Nancy to Avoid String index out of bound exception for Non-Mandatory Fields
						if(mandatoryFlag.equals("N")) {
							if(i >= al.size()) {
								data="";
							 } else {
								 data = al.get(columnPosition.get(i) - 1).trim();// Trim add by Mohan Raj.V to Fix the CLM Issue S.No 370 
							 }
						}
						else {	
							data = al.get(columnPosition.get(i) - 1).trim();// Trim add by Mohan Raj.V to Fix the CLM Issue S.No 370 
						}	 
						//nancy:ends
						
					} else if (fileType != null && fileType.equals("F")) {

						String fromValue = columnFromPos.get(i);
						String toValue = columnToPos.get(i);
						mandatoryFlag = columnMandatoryFlag.get(i).toString();
						data = ""; // Added by Mohan Raj.V on 24-03-16 for clearing the previous set data value 	
						if(fromValue.matches("\\d+") && toValue.matches("\\d+")){
							//Added By Nancy to Avoid String index out of bound exception for Non-Mandatory Fields
							int dataLen = drLine.length();
							if(mandatoryFlag.equals("N")){
								if(dataLen < Integer.parseInt(toValue)){
									if(dataLen < Integer.parseInt(fromValue)){
										fromValue = Integer.toString(dataLen+1);
										toValue = Integer.toString(dataLen);
									}else{
										toValue = Integer.toString(dataLen);
								   }
								}
							}
							//nancy:ends
							data = drLine.substring(Integer.parseInt(fromValue)-1, Integer.parseInt(toValue)).trim();
						}
					}
					
					if(ReconConstants.CARDNUMBER.equals(columnName.get(i)))  //Mask card number field added by vinoth
						data=StringUtils.maskNumber(data.trim()).trim();
					//else if("PG_MSG".equals(columnName.get(i))) 
					//	data="";
					
					data=doDataValidation(data, mandatoryFlag, elementForm, i);

					resultElements.add(data);
					
					//Code Added by Anil Kumar D for Footer Changes on 08-03-2016
					int fieldId = 0;
					int chkFieldId = 0;
					String chkConstant = "";
					String checkValue = "";
					String ctrlType = "";
					boolean rowIdentification = true;
					controlFlagCount = inputFileForm.getControlTagCount() != null ? inputFileForm.getControlTagCount() : 0;
					if (controlFlagCount > 0) {
						Map<String, List<FooterConfiguration>> footerConfiguration = inputFileForm.getFooterConfig();
						List<FooterConfiguration> footerConfig = footerConfiguration.get(temp_id);

						for (int j = 0; j < controlFlagCount; j++) {
							chkFieldId = footerConfig.get(j).getControlCheckField() != null ? footerConfig.get(j).getControlCheckField() : 0;
							chkConstant = footerConfig.get(j).getControlCheckConstant() != null ? footerConfig.get(j).getControlCheckConstant() : "";
							if (chkFieldId > 0) {
								for (int k = 0; k < columnID.size(); k++) {
									int id = columnID.get(k) != null ? columnID.get(k) : 0;
									if (id == chkFieldId) {
										if(fileType != null && fileType.equals("D")){
											al = Arrays.asList(drLine.split(Pattern.quote(inputFileForm.getDelimiter())));
											checkValue = al.get(chkFieldId - 1);
											break;
										}else if(fileType != null && fileType.equals("F")) {
											if(footerConfig.get(j).getControlDataFromPosition().toString().matches("\\d+") && footerConfig.get(j).getControlDataToPosition().toString().matches("\\d+")){
												checkValue = drLine.substring((Integer.parseInt(columnFromPos.get(j))-1), Integer.parseInt(columnToPos.get(j)) -1 ).trim();
												break;
											}else{
											}			
										}
									}
								}
								if (checkValue != null && !checkValue.equals("")) {
									if (!chkConstant.equals(""))
										if (!checkValue.equalsIgnoreCase(chkConstant))
											rowIdentification = false;
										else
											rowIdentification = true;
								} else {
									rowIdentification = true;
								}
							}
							if(rowIdentification) {
								Double rowCount = 0.0;
								ctrlType = footerConfig.get(j).getControlType() != null ? footerConfig.get(j).getControlType() : "";
								if(ctrlType.equalsIgnoreCase("CNT") && countStatus == true){
									if(counter.isEmpty() || counter.get(footerConfig.get(j).getControlId()) == null ){
										rowCount = 0.0;
									} else{
										rowCount = counter.get(footerConfig.get(j).getControlId());
									}
									rowCount =  rowCount + 1;
									counter.put(footerConfig.get(j).getControlId(), rowCount);
									countStatus = false;
									break;
								}else if(ctrlType.equalsIgnoreCase("SUM")){
									fieldId = footerConfig.get(j).getControlDataRecordField() != null ? footerConfig.get(j).getControlDataRecordField() : 0;
									Integer fId = Integer.parseInt(columnID.get(i).toString());
									if(fId == fieldId){
										//logger.debug("field identified for sum");
										double sumValue = 0.0;
										if(counter.isEmpty() || counter.get(footerConfig.get(j).getControlId()) == null){
											sumValue = 0.0;
										} else{
											sumValue = counter.get(footerConfig.get(j).getControlId());
										}
										sumValue = sumValue + Double.parseDouble(data);
										counter.put(footerConfig.get(j).getControlId(), sumValue);
										break;
									}
								}
							}
						}
					}
					//End for Footer Changes

					//Logic to calculate Footer control tag values

				/*	controlFlagCount = inputFileForm.getControlTagCount() != null ? inputFileForm.getControlTagCount() : 0;
					if(controlFlagCount>0){
						String ctrlType = "";
						int fieldId = 0;
						int chkFieldId = 0;
						String chkConstant = "";
						String checkValue = "";
						boolean rowIdentification = true;
						if(mandatoryFlag.equals("Y")){

							for (int j = 0; j < controlFlagCount; j++) {
								chkFieldId = controlCheckField.get(j) != null ? controlCheckField.get(j) : 0;
								chkConstant = controlCheckConstant.get(j) != null ? controlCheckConstant.get(j) : "";

								if (chkFieldId > 0) {
									for (int k = 0; k < columnID.size(); k++) {
										int id = columnID.get(k) != null ? columnID.get(k) : 0;

										if (id == chkFieldId) {
											if(columnFromPos.get(k).matches("\\d+") && columnToPos.get(k).matches("\\d+")){
												checkValue = drLine.substring(Integer.parseInt(columnFromPos.get(k))-1, Integer.parseInt( columnToPos.get(k))).trim();
												break;
											}else{

											}			
										}
									}
									if (checkValue != null && !checkValue.equals("")) {
										if (!chkConstant.equals(""))
											if (!checkValue.equalsIgnoreCase(chkConstant))
												rowIdentification = false;
											else
												rowIdentification = true;
									} else {
										rowIdentification = true;
									}
								}
								if(rowIdentification) {

									ctrlType = controlType.get(j)!=null?controlType.get(j):"";
									if(ctrlType.equalsIgnoreCase("CNT") && countStatus == true){

										int rowCount = 0;
										if(calculatedValues.size() > 0){
											rowCount=calculatedValues.get(j)!=null?Integer.parseInt(calculatedValues.get(j).toString()):0;
											calculatedValues.remove(j);	 
										}
										else{
											rowCount = 0;
										}
										rowCount++;
										calculatedValues.add(j,rowCount);
										countStatus = false;
										break;

									}else if(ctrlType.equalsIgnoreCase("SUM")){

										fieldId = controlDataRecordField.get(j) != null ? controlDataRecordField.get(j) : 0;

										Integer fId = Integer.parseInt(columnID.get(i).toString());
										if(fId == fieldId){
											//logger.debug("field identified for sum");
											double sumValue = 0.0;
											if(calculatedValues.size()>0){
												sumValue = calculatedValues.get(j)!=null?Double.parseDouble(calculatedValues.get(j).toString()):0.0;
												calculatedValues.remove(j);
											}else
												sumValue = 0.0;

											sumValue = sumValue + Double.parseDouble(data);
											calculatedValues.add(j,sumValue);
											break;
										}
									}
								}
							}
						} else {
							logger.error("Control Flag Element  Should be the configured as Mandatory!");
							throw new ReconUserDefinedException(
									"Control Flag Element  Should be the configured as Mandatory!");
						}
					}*/
				}//for
				//-----Added By Mohan Raj.V for appending REV_FLAG for TLF and PTLF starts...
				int templateTypeId=Integer.parseInt(elementForm.getTemplateTypeId());
				if(templateTypeId!=0 && (templateTypeId == 1 || templateTypeId == 2 || templateTypeId == 5 || templateTypeId == 6))//1- TLF,2-PTLF, 5- NFS Issuer, 6-NFS ACCQUIRER 
				{
					resultElements = frameREVFLAG(drLine, elementForm, resultElements, templateTypeId);
				}
				//------ends...
			}
		} catch(ReconUserDefinedException e) {
			logger.error("ReconUserDefinedException While Performing Data Element Validation for a line : "+drLine+" ", e);
			throw new ReconUserDefinedException("ReconUserDefinedException |  InputfileConfigReader  |  "+colName+" |  " +data+ " | " +e.getMessage());
		} catch(Exception e) {
			logger.error("Exception While Performing Data Element Validation for a line : "+drLine+" ", e);
			throw new ReconUserDefinedException("Exception |  InputfileConfigReader  | "+colName+"  | " +data+ " | " + e.getMessage());
		} finally {
			columnPosition = columnType = columnFormat = columnID = columnLength = null;
			columnName = columnFromPos = columnToPos =  columnFormatDesc = columnMandatoryFlag = null;
		}

		return resultElements;
	}

	//Added By Mohan Raj.V to add update REV_flag in java instead of Database 
	public List<String> frameREVFLAG(String drLine,TemplateForm elementForm, List<String> resultElements, int templateTypeId )throws Exception
	{
		String REV_FLAG = "N" ;
		String MSG_TYPE = "";
		String REMARKS = "";
		String TRAN_AMT_2 = "";
		Long TRAN_AMOUNT = 0L;
		try
		{
			if( templateTypeId == 1 || templateTypeId == 2 ) {
				// getting the index of the column in the list
				int rvsl_Code_Index = elementForm.getColumnName().indexOf("RVSL_CDE") ; // .indexof give the position of RVSL_CODE in the arraylist
				int tran_Code_Index = elementForm.getColumnName().indexOf("TRAN_CODE");
				int tran_RespCode_Index = elementForm.getColumnName().indexOf("TRAN_RESP_CODE");
				int msg_Type_Index = elementForm.getColumnName().indexOf("MSG_TYP");
				int tran_Amt_2_Index = elementForm.getColumnName().indexOf("TRAN_AMT_2");
				int tran_amount_Index = elementForm.getColumnName().indexOf("TRAN_AMOUNT");
				if( rvsl_Code_Index != -1 && tran_Code_Index != -1 && tran_RespCode_Index != -1 && msg_Type_Index != -1 && tran_Amt_2_Index != -1 && tran_amount_Index != -1 ){
					// getting the value of the required column using the above index
					String rvslCode = resultElements.get(rvsl_Code_Index);
					String tranCode = resultElements.get(tran_Code_Index);
					String tranRespCode = resultElements.get(tran_RespCode_Index);
					String msgType = resultElements.get(msg_Type_Index);
					String tran_Amt_2 = resultElements.get(tran_Amt_2_Index);
					TRAN_AMOUNT = Long.parseLong( resultElements.get( tran_amount_Index ) );
					// Logic to check whether the amt2 field contains character if so it was replaced with '0' added by Mohan Raj.V
					if (! tran_Amt_2.matches("[0-9]+")) {
						 if (tran_Amt_2 != null && !tran_Amt_2.isEmpty()) {
					        for (char c : tran_Amt_2.toCharArray()) {
					            if (! Character.isDigit(c)) {
					            	tran_Amt_2 = tran_Amt_2.replace(c, '0');
					            }
					        }
					    }
					}
					Long tran_Amt_2_int = Long.parseLong(tran_Amt_2);
//					if((!"00".equals( rvslCode ) && rvslCode.length()!=0 )){ //commented by Mohan Raj.V - need to verify 
					if(( "0420".equals( msgType ) )){
						if(! "20".equals( rvslCode ) ) {
							if(  ( "0420".equals( msgType ) ) || ( ( !"30".equals( tranCode ) &&  !"70".equals( tranCode )  &&  !"81".equals( tranCode )  ) && ( "000".equals( tranRespCode ) || "001".equals( tranRespCode ) ) )  ) {
								if(!( ( TRAN_AMOUNT != tran_Amt_2_int )&& ( tran_Amt_2_int > 0 ) )){
									REV_FLAG = "F";
									MSG_TYPE = "0420";
									REMARKS = "FULL REVERSAL KNOCKOFF";
									TRAN_AMT_2 = "0";					
									resultElements.set(msg_Type_Index, MSG_TYPE);
									resultElements.set(tran_Amt_2_Index, TRAN_AMT_2);
									resultElements.add(REV_FLAG);
									resultElements.add(REMARKS);
								} else {
									REV_FLAG = "P";
									MSG_TYPE = "0420";
									TRAN_AMOUNT = TRAN_AMOUNT - tran_Amt_2_int; 
									TRAN_AMT_2 = "0";
									resultElements.set(msg_Type_Index, MSG_TYPE);
									resultElements.set(tran_amount_Index, TRAN_AMOUNT.toString()); 							
									resultElements.set(tran_Amt_2_Index, TRAN_AMT_2); 
									resultElements.add(REV_FLAG);
									resultElements.add(REMARKS);
								}
							}
						} else {
							REV_FLAG = "S";
							resultElements.add(REV_FLAG);
							resultElements.add(REMARKS);
						}
					} else {
						resultElements.add(REV_FLAG);
						resultElements.add(REMARKS);
					}
				} else {
					// FOR ADMIN TRANSACTION IT WILL COME TO ELSE BLOCK 
	//				logger.error("Check Whether the Template contains these columns :RVSL_CDE, TRAN_CODE, TRAN_RESP_CODE, MSG_TYP, TRAN_AMT_2, TRAN_AMOUNT ");
					resultElements.add(REV_FLAG);
					resultElements.add(REMARKS);
				}
			} else if( templateTypeId == 5 || templateTypeId == 6 )  {  // TemplateTypeId == 5 ( for NFS ISSUER) & 6 (for NFS ACCQUIRER) 
				int tran_RespCode_Index = elementForm.getColumnName().indexOf("TRAN_RESP_CODE");
				int tran_Amt_2_Index = elementForm.getColumnName().indexOf("TRAN_AMT_2");
				int tran_amount_Index = elementForm.getColumnName().indexOf("TRAN_AMOUNT");
				if(tran_RespCode_Index != -1 && tran_Amt_2_Index != -1 && tran_amount_Index != -1) {
					String tranRespCode = resultElements.get(tran_RespCode_Index);
					String tran_Amt_2 = resultElements.get(tran_Amt_2_Index);
					TRAN_AMOUNT = Long.parseLong( resultElements.get( tran_amount_Index ) );
					// Logic to check whether the amt2 field contains character if so it was replaced with '0' added by Mohan Raj.V
					if (! tran_Amt_2.matches("[0-9]+")) {
						 if (tran_Amt_2 != null && !tran_Amt_2.isEmpty()) {
					        for (char c : tran_Amt_2.toCharArray()) {
					            if (! Character.isDigit(c)) {
					            	tran_Amt_2 = tran_Amt_2.replace(c, '0');
					            }
					        }
					    }
					}
					Long tran_Amt_2_int = Long.parseLong(tran_Amt_2);
					if( "28".equals( tranRespCode ) ) {
						REV_FLAG = "F";
						REMARKS = "FULL REVERSAL KNOCKOFF";
						resultElements.add(REV_FLAG); 
						resultElements.add(REMARKS);
					} else if( ( "26".equals( tranRespCode )) && TRAN_AMOUNT != tran_Amt_2_int && tran_Amt_2_int > 0 ) {
						REV_FLAG="P";
						resultElements.add(REV_FLAG);
						resultElements.add(REMARKS);
					} else {
						resultElements.add(REV_FLAG);
						resultElements.add(REMARKS);
					}
				} else {
					resultElements.add(REV_FLAG);
					resultElements.add(REMARKS);
				}
			}
		}catch(Exception e)
		{
//			logger.error("Exception occcured in Framing REV_FLAG : "+e);
//			logger.error("Exception occured Line is : "+drLine);
			resultElements.add(REV_FLAG);
			resultElements.add(REMARKS);
		}
		return resultElements;
	}
	/**
	 * @param elementValues List Of Element Values
	 * @param tempid_subTemp Template And Sub Template Id
	 * @param bufferWritermap MAp For DAT File reference
	 * @throws ReconUserDefinedException
	 */
	public boolean SplitData(List<String> elementValues, String tempid_subTemp,
			Map<String, BufferedWriter> bufferWritermap, String fileNameDtls, TemplateForm templateForm, LoopBack loopBack,String fileName,boolean isFileDateLogged, InputFileReaderDao readerDao)
			throws ReconUserDefinedException {		

		StringBuffer recordContent = new StringBuffer();
		BufferedWriter bufferWriter = null;
		List<String> columnName = null;
		columnName = templateForm.getColumnName();
		if (elementValues != null && elementValues.size() > 0) {
			recordContent.append(fileNameDtls + "~|");
			recordContent.append(fileName + "~|"); //Added By Sushmita on 26-12-2017
			for (int i = 0; i < elementValues.size(); i++) {
				// recordContent = recordContent + elementValues.get(i) + "|";
			// Added by Mohan Raj.V on 29-03-2016 to save terminal id for admin EJ Transaction
				if( "ADMIN EJ".equalsIgnoreCase( templateForm.getTemplateTypeDesc() ) ) {
					if( "TERM_ID".equalsIgnoreCase( columnName.get(i) ) ) {
						recordContent = recordContent.append( terminalId + "~|" );
					} else {
				recordContent = recordContent.append(elementValues.get(i) + "~|");
					}
				} else {
					recordContent = recordContent.append(elementValues.get(i) + "~|");
				}
			}
		}
		try {
			//			logger.debug("in split data() : " + recordContent);
			bufferWriter = bufferWritermap.get(tempid_subTemp);
			bufferWriter.write(recordContent + "\n");
			bufferWriter.flush();
			recordContent.delete(0, recordContent.length());
			
			//Added by vinoth for file DATE logging in DB
			
			if(!isFileDateLogged)
			{
				isFileDateLogged  = this.logFileDate(tempid_subTemp.split("-")[0], loopBack, fileName, fileNameDtls, readerDao);
				
				
				logger.debug("logFileDate isFileDateLogged : "+isFileDateLogged);
			}
			//Ends vinoth
			
			
		} catch( ReconUserDefinedException e ){ 
			logger.error("Extraction Fails in File Date Sequence Check ");
			throw new ReconUserDefinedException(e);
		}catch (IOException e) {
			logger.error("IO Error While splitting the data elements for writing into dat file" + e);
			throw new ReconUserDefinedException("IO Error While splitting the data elements for writing into dat file");
		} catch (Exception e) {
			logger.error(" Error While splitting the data elements for writing into dat file" + e);
			throw new ReconUserDefinedException("Error While splitting the data elements for writing into dat file");
		}
		return isFileDateLogged;
	}

	/**
	 * @param fileName
	 *            Input File Name
	 * @param form
	 *            Input File Configuration Form
	 * @return boolean true or false
	 * @throws ReconUserDefinedException
	 */
	public boolean checkFileNameConvention(String fileName, InputFileConfigurationForm form)
			throws ReconUserDefinedException {

		int i = 0;
		boolean result = true;
		String msConstantFrmFileName = "";
		String msConvention = "";
		String seqCheckData = "";
		String seqDataFormat = "";

		try {

			String msNamingConv = form.getFileNameConventionFormat();
			String msConstant = form.getDefineConstant();
			logger.debug(" In checkFileNameConvention() method msNamingConv : " + msNamingConv + " msConstant : "
					+ msConstant);

			for (int j = 0; j < msNamingConv.length(); j++) {
				msConvention = msNamingConv.substring(j, j + 1);

				if (msConvention.equals("K")) {
					msConstantFrmFileName = msConstantFrmFileName + fileName.substring(j, j + 1);
					if (!(msConstant.substring(i, i + 1).equals(fileName.substring(j, j + 1)))) {

						result = false;
						throw new ReconUserDefinedException("Invalid FileName found  " + msConstant.substring(i, i + 1)
								+ " Not Present.");
					}
					i = i + 1;
				} else if (msConvention.equals("D")) {
					seqCheckData = seqCheckData + fileName.substring(j, j + 2);
					seqDataFormat = seqDataFormat + "DD";

					if (!(Integer.parseInt(fileName.substring(j, j + 2)) >= 1 && Integer.parseInt(fileName.substring(j, j + 2)) <= 31)) {
						result = false;
						throw new ReconUserDefinedException( "Invalid Day found in FileName " + fileName.substring(j, j + 2));
					}
					j = j + 1;
				} else if (msConvention.equals("M")) {
					if (msNamingConv.substring(j, j + 2).equals("MM")) {
						seqCheckData = seqCheckData + fileName.substring(j, j + 2);
						seqDataFormat = seqDataFormat + "MM";

						if (!(Integer.parseInt(fileName.substring(j, j + 2)) > 0 && Integer.parseInt(fileName.substring(j, j + 2)) <= 12)) {
							result = false;
							throw new ReconUserDefinedException( "Invalid Month found in FileName " + fileName.substring(j, j + 2));
						}
						j = j + 1;
					} else {
						if (!(Integer.parseInt(fileName.substring(j, j + 2)) >= 0 && Integer .parseInt(fileName.substring(j, j + 2)) <= 59)) {
							result = false;
							throw new ReconUserDefinedException( "Invalid Time found in FileName " + fileName.substring(j, j + 2));
						}
						j = j + 1;
					}
				}else if(msConvention.equals("Y")){

					seqCheckData = seqCheckData + fileName.substring(j,j+1);
					seqDataFormat= seqDataFormat + "Y";

					if(!( Integer.parseInt(fileName.substring(j,j+1)) >= 0 && Integer.parseInt(fileName.substring(j,j+1)) <= 9 )){

						result = false;
						throw new ReconUserDefinedException("Invalid date found in FileName "+fileName.substring(j,j+1));
					}
					//j = j + 1;
				} else if (msConvention.equals("C")) {
					if (!(Integer.parseInt(fileName.substring(j, j + 1)) >= 0 && Integer.parseInt(fileName.substring(j, j + 1)) <= 9)) {
						result = false;
						throw new ReconUserDefinedException( "Invalid counter found in FileName " + fileName.substring(j, j + 2));
					}
				}else if(msConvention.equals("H")){
					if(!( Integer.parseInt(fileName.substring(j,j+2)) >= 0 && Integer.parseInt(fileName.substring(j,j+2)) < 24 ))
					{
						result = false;
						throw new ReconUserDefinedException("Invalid Time found in FileName "+fileName.substring(j,j+2));
					}
					j = j + 1;
				} else if (msConvention.equals("S")) {
					if (!(Integer.parseInt(fileName.substring(j, j + 2)) >= 0 && Integer .parseInt(fileName.substring(j, j + 2)) <= 59)) {

						result = false;
						throw new ReconUserDefinedException( "Invalid Time found in FileName " + fileName.substring(j, j + 2));
					}
					j = j + 1;
				} else if (msConvention.equals(".")) {
					if (!(fileName.substring(j, j + 1)).equals(fileName.substring(j, j + 1))) {

						result = false;
						throw new ReconUserDefinedException( "Naming convention not folowed in FileName. Required Format is : "
								+ msNamingConv);
					}
				}
			}//for

		}catch(Exception e) {
			logger.error(e);
			throw new ReconUserDefinedException(e);
		}
		return result;

	}

	/**
	 * 
	 * @param tempDirName entire directory name (it should be ending with file separator)  
	 * @param tempFileName file name.
	 * @return data file location
	 * @throws Exception
	 */
	public String getDatFileLocation(String tempDirName, String tempFileName) throws Exception  {

		try {
			logger.debug(" in get data file location () temp dir name : "+tempDirName+ " temp file name is : "+tempFileName); 

			if (!tempDirName.endsWith(File.separator)) {
				tempDirName = tempDirName + File.separator;
			}

			tempFileName = tempFileName + ".dat";

			File dir = new File(tempDirName);

			if (!dir.exists() || !dir.isDirectory()) {
				dir.mkdir();
			}
		} catch (Exception e) {
			logger.error("Exception is : " + e);
			throw new Exception("Exception Occured while creating  Dat File Location" + e);
		}

		return tempDirName + tempFileName;
	}

	

	/*
	 * @param elementValues List Of Element Values
	 * @param templateConfigMap Map for template configuration
	 * @return boolean true or false
	 * @throws Exception
	 * 
	 */
	// Added by Mohan Raj.V on 16/03/16 for mandatory check validation
	public boolean invalidInputValidation(List<String> elementValues , Map<String, TemplateForm> templateConfigMap, TemplateForm templateForm,String drLine) throws ReconUserDefinedException{
		boolean status=true;	
		try {
			ArrayList<String> mandatoryFlag = templateForm.getColumnMandatoryFlag();
			for (int i=0 ; i< templateForm.getColumnName().size() ; i++ ){
				if( ("Y").equalsIgnoreCase(mandatoryFlag.get(i)) ){
					if( ("").equalsIgnoreCase(elementValues.get(i)) ){
						status = false;
						logger.error("Exception in Transaction Line : "+drLine);
						logger.error(" Data is Empty! For The Column  "+(i+1)+" Column Name :"+templateForm.getColumnName().get(i));
						throw new ReconUserDefinedException(" Data is Empty while Some valid Data is being Expected : "+templateForm.getColumnName().get(i));
					}
				}
			}
		}catch(Exception e) {
			logger.error("in catch block "+e);
			throw new ReconUserDefinedException(e.getMessage());
		}
		return status;
	}

	@Override
	public Integer call() throws Exception {
		
		try {
//			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
			logger.info("Thread Started for the File :"+this.fileName);
			
			logger.debug("Enter into call() : fileName is : "+fileName+ " fileNameDtls : "+fileNameDtls);
			
			this.readFileViaThread(this.inputForm, this.fileName, this.templateConfigMap, this.loopBack, this.fileNameDtls,this.readerDao);
			
			//this.deleteInputFile(inputForm.getFileLocalPath(), fileName);  //Adde by vinoth for PADSS on 04-10-2016						
			
			//logic to move the input file to del dir..
			 String filePath = inputForm.getFileLocalPath();
			 String delDirPath = filePath+File.separator+"DelDir";
				logger.debug("logic to move extracted file to del dir : "+this.fileName);
				File oldFile = new File(filePath + this.fileName);
				File delDirectoryPath = new File(delDirPath+ File.separator + this.fileName);
				Boolean statFlag = null;
				if( ! delDirectoryPath.exists() ) { 	
					statFlag = oldFile.renameTo(delDirectoryPath);
				}
			readerDao.updateExtractedFileStatus(inputForm.getFileId(), fileName, "C", loopBack,"Completed");  // update the file running status as 'Completed'
			
			logger.info("Thread completed for the File :"+this.fileName);
			return 1;
			
		} catch (Exception e) {
			logger.error("Exception occured in call() : "+e);
			logger.error("Exception Occured while extracting file : "+fileName+ " exception is  : "+e);
			try{
				// update the file running status as 'Exception (E)' in
				readerDao.updateExtractedFileStatus(inputForm.getFileId(), fileName, "E", loopBack,e.getMessage());
				
			} catch (Exception e1) {
				logger.error("Exception occured in call() catch block while updating extracted file status : "+e1);
			}
			return 0;
		}
				
	}

	
	@SuppressWarnings("unchecked")
	private void readFileViaThread(InputFileConfigurationForm inputForm, String fileName,Map<String, TemplateForm> templateConfigMap, LoopBack loopBack, Map<String, String> fileNameDtls, InputFileReaderDao readerDao) throws ReconUserDefinedException{

		String filePath = "";
//		String destinationPath = ""; // logic to write in separate disc
		String drLine = "";
		int len = inputForm.getControlTagCount() != null ? inputForm.getControlTagCount() : 0;
		String headerAvailableCheck = inputForm.getFileHeaderAvailable();
		boolean footerStatus = false;
		boolean isDataExsit=false;
		boolean isFileDateLogged = false;
		boolean headerResult = false;

		BufferedReader bufferReader = null;
		Map<String, DrIdentificationForm> drIdyMap = null;
		Map<String, BufferedWriter> bufferWritermap = null;
		counter = new HashMap<Long, Double>();//added by nancy 
		for (int i = 0; i < len; i++) {
			calculatedValues.add(null);
		}
		try{

			logger.info("Entered Into readFile Method");
			filePath = inputForm.getFileLocalPath();
//			destinationPath = inputForm.getFileLocalDestinationPath();

			bufferReader = new BufferedReader(new FileReader(filePath + fileName));	// To read the input file
			drIdyMap = inputForm.getDrIdentifierDtlsMap();		// To bring all templates related to input file along with their DR identification configuration
			bufferWritermap = createDatFiles(filePath, fileName, drIdyMap);	// To create DAT file
//			bufferWritermap = createDatFiles(destinationPath, fileName, drIdyMap);	// To create DAT file logic to write in separate disc 
			Map<String, String> tranCodeMap = readerDao.getTranCodeDetails(loopBack);

			if (bufferReader != null) {
				if (inputForm.getDataFormat().equalsIgnoreCase("F")) {

					if ((headerAvailableCheck != null && headerAvailableCheck != "") && headerAvailableCheck.equals("Y")) {
						ArrayList<Integer> linePos = inputForm.getFileHeaderLinePosition();
						int maxLine = Collections.max(linePos);
						StringBuffer allHeaderLines = new StringBuffer();
						String header = bufferReader.readLine();

						if (maxLine != 1 && maxLine > 1) {
							for (int count = 1; header != null && count <= maxLine; count++) {
								allHeaderLines.append(header);
								if (count != maxLine) {
									allHeaderLines.append("\n");
									header = bufferReader.readLine();
								}
							}
							header = allHeaderLines.toString();
						}
						if (header != null) {
							if("D".equalsIgnoreCase(inputForm.getFileType())  ){//Added By Nancy to Skip header line for delimeter file 
								headerResult = true;
							}else{
								 headerResult = headerValidation.validateHeader(header, inputForm, fileName,loopBack);
							}
							if (!headerResult) {
								logger.error("Header validation failed . Result is : " + headerResult);
								throw new ReconUserDefinedException("Invalid Header for file : ");
								// TODO : need to consider validate header() response
							}
						}
					}

					drLine = bufferReader.readLine();
					while (drLine != null && !drLine.trim().isEmpty()) {
						if (!(drLine.trim().equals(""))) {// If not empty line
							if (inputForm.getFooterAvailable().equalsIgnoreCase((ReconConstants.CHECK_FLAG_YES))) {
								if (footerValidation.isFooterRecord(drLine, inputForm)) {
									InputFileConfigurationForm inputFileConfig = readerDao.fetchFooterConfiguation(inputForm, loopBack);	//Added by Anil Kumar D
									footerStatus = footerValidation.checkFooter(drLine, this.counter, inputFileConfig);
									break;
								}
							}
							if (!footerStatus) {
								String tempId_subTempId = findTemplate(drLine, inputForm,"");
								if (tempId_subTempId != null && !(tempId_subTempId.equals(""))) {
									TemplateForm currentTempForm = templateConfigMap.get(tempId_subTempId);
									List<String> drElementValues = performDataElementValidation(drLine, inputForm,currentTempForm);
									
									if(drElementValues.size()>0) isDataExsit=true; //Added by vinoth for mantis id:14579
									
									isFileDateLogged = SplitData(drElementValues, tempId_subTempId, bufferWritermap,fileNameDtls.get(fileName), currentTempForm,loopBack,fileName,isFileDateLogged, readerDao);
								}
							}
						}
						drLine = bufferReader.readLine();
					}
					 
					//if(KeyCache.doesKeyExist(inputForm.getInstitutionCode())) KeyCache.removeKey(inputForm.getInstitutionCode());  //Added by vinoth
					
					if(!isDataExsit){
						logger.info("No data found in the dat file ");
						throw new ReconUserDefinedException("No data found in the dat file ");
					}
						
						
				} else if(inputForm.getDataFormat().equalsIgnoreCase("K")) { //DR FORMAT IS KEYBASED

					List<String> drElementValues = new ArrayList<String>();
					List<String> mergedrElementValues = new ArrayList<String>();					
					List<List<String>> mergeAndFixedValuesList = new ArrayList<List<String>>();
					String columnIds = "";
					String tempId_subTempId = "";
					String temp_tempId = "";
					List<Object> temp_SubTempId_ElementValues= null;
					List<Object> mergeTemp_SubTempId_ElementValues= null;
					String parent = "";
					byte[] isoB =   null;
					Charset utf8charset = null;
					Charset iso88591charset = null;
					ByteBuffer inputBuffer = null;
					CharBuffer decodeUtfData = null;
					ByteBuffer outputBuffer = null;
					byte[] outputData = null;
					boolean nextFlag = false;
					boolean next2Flag = false;
					boolean next5Flag = false;
					boolean fixedFormatFlag = true; //Added by Mohan Raj.V for Reading Fixed format in keybased
					TemplateForm nextFlagTempForm = null;
					TemplateForm currentTempForm = null; // Added by Mohan Raj.V for invalidInput validationMethod
					TemplateForm tempForm = null; // Added by Mohan Raj.V for invalidInput validationMethod
					StringBuffer next2TempString = new StringBuffer("");
					List<String> temDrelm = new ArrayList<String>(); // added by vinoth
					if ((headerAvailableCheck != null && headerAvailableCheck != "")
							&& headerAvailableCheck.equals("Y")) {
						ArrayList<Integer> linePos = inputForm.getFileHeaderLinePosition();
						int maxLine = Collections.max(linePos);
						StringBuffer allHeaderLines = new StringBuffer();
						String header = bufferReader.readLine();

						if (maxLine != 1 && maxLine > 1) {
							for (int count = 1; header != null && count <= maxLine; count++) {
								allHeaderLines.append(header);
								if (count != maxLine) {
									allHeaderLines.append("\n");
									header = bufferReader.readLine();
								}
							}
							header = allHeaderLines.toString();
						}
						if (header != null)
							headerValidation.validateHeader(header, inputForm, fileName, loopBack);
					}

					drLine = bufferReader.readLine();
					String previousParent = "";
					while(drLine != null){
						
						if(!drLine.trim().isEmpty()){// if not empty line
							
							isoB =   drLine.getBytes() ;
							utf8charset = Charset.forName("UTF-8");
							iso88591charset = Charset.forName("ISO-8859-15");
							inputBuffer = ByteBuffer.wrap(isoB);
							// decode UTF-8
							decodeUtfData = utf8charset.decode(inputBuffer);
							// encode ISO-8559-1
							outputBuffer = iso88591charset.encode(decodeUtfData);
							outputData = outputBuffer.array();
							drLine = (new String(outputData, Charset.forName("ISO-8859-15") ) );
							
							//Added by vinoth for footer validation
							if (inputForm.getFooterAvailable().equalsIgnoreCase((ReconConstants.CHECK_FLAG_YES))) {
								if (footerValidation.isFooterRecord(drLine, inputForm)) {
									InputFileConfigurationForm inputFileConfig = readerDao.fetchFooterConfiguation(inputForm, loopBack);	//Added by Anil Kumar D
									footerStatus = footerValidation.keyBasedCheckFooter(drLine, this.calculatedValues, inputFileConfig);
								}
							}
							
							
							if(!nextFlag){
							//To Find Template Id By Passing Data Record
								temp_tempId = findTemplate(drLine, inputForm, previousParent);
							tempId_subTempId = temp_tempId.split("~")[0];
							
							
							if(tempId_subTempId != null && !(tempId_subTempId.equals(""))){
								// To Get DR FORMAT Configuration By using Template Id
								KeyBasedDataRecord keyBasedDr = DRInfoForKeyBased (drLine, drIdyMap,tempId_subTempId);

								if(keyBasedDr != null){
									currentTempForm = templateConfigMap.get(tempId_subTempId);
									columnIds  = keyBasedDr.getColumnIds();
									//Logic For Parent Transaction
									if(keyBasedDr.getParentChildIndicator().equals("P")){
										previousParent = keyBasedDr.getKey(); //added by Mohan Raj.V				
										//  containsnext logic is added by Mohan Raj.V to check for contains and need to read next line on 30-03-18
										if(keyBasedDr.getStrIdentifier().equals("next") || keyBasedDr.getStrIdentifier().equals("containsNext") ){  // append next line also and read as single line if parent recode identifier is next - added by vinoth(09-09-16)
											drLine = next2TempString.append(drLine).append(bufferReader.readLine()).toString();																					
										}else if(keyBasedDr.getStrIdentifier().equals("next_2")){  // append next line also and read as single line if parent recode identifier is next - added by vinoth(09-09-16)
											drLine = next2TempString.append(drLine).append(bufferReader.readLine()).append(bufferReader.readLine()).toString();																					
										} else if ( keyBasedDr.getStrIdentifier().equals("fixed") ) {
											 //added by Mohan Raj to read Advisory File (this logic will read all the line TILL it Find End Identifier) 
											String parent_tempId_subTempId = tempId_subTempId ;
											drLine = bufferReader.readLine();
											
											while(drLine != null){
												
//												tempId_subTempId = findTemplate(drLine, inputForm);
												temp_tempId = findTemplate(drLine, inputForm, previousParent);
												tempId_subTempId = temp_tempId.split("~")[0];
												 keyBasedDr = DRInfoForKeyBased (drLine, drIdyMap,tempId_subTempId);
												  
												 if(keyBasedDr != null && ! "".equals( keyBasedDr.getKey() )){
													 

													 if(keyBasedDr.getColumnIds() != null)
														 columnIds = keyBasedDr.getColumnIds() ;
													 
													 if(keyBasedDr.getStrIdentifier().equals("end")){
														 if( drLine.contains(keyBasedDr.getKey())){
															 fixedFormatFlag = false;
														 }
													 }
												 }
												if(!drLine.trim().isEmpty() && fixedFormatFlag ){ // if not empty line
													if (parent_tempId_subTempId != null && !(parent_tempId_subTempId.equals(""))) {
														 currentTempForm = templateConfigMap.get(parent_tempId_subTempId);
														drElementValues = performDataElementValidation(drLine, inputForm,currentTempForm);
//														temp_SubTempId_ElementValues = drElementValues;
														SplitData(drElementValues, parent_tempId_subTempId, bufferWritermap,fileNameDtls.get(fileName), currentTempForm,loopBack,fileName,isFileDateLogged,readerDao);
														drElementValues.clear();
													}
												}
												if( fixedFormatFlag ) {
													drLine = bufferReader.readLine();
												} else {
													drLine = null;
												}
											}
										}else if("merge".equals(keyBasedDr.getStrIdentifier())){
											parent = keyBasedDr.getKey();
											performKeyBasedDataElementValidation(drLine, fileName,inputForm,  currentTempForm, tempId_subTempId,columnIds,mergedrElementValues,tranCodeMap);
										}
										
										if( fixedFormatFlag && !"merge".equals(keyBasedDr.getStrIdentifier())) { // if it is false it is Fixed so no need to execute this block
											parent = keyBasedDr.getKey();
											if(temp_SubTempId_ElementValues != null){ // To Write Line in DAT File For Last Complete(Parent and Child) Transaction
												tempForm  = templateConfigMap.get(temp_SubTempId_ElementValues.get(0).toString()); //added by MOhan Raj.V to resolve issue while reading admin txn
												isFileDateLogged  = SplitData((List<String>)temp_SubTempId_ElementValues.get(1), temp_SubTempId_ElementValues.get(0).toString(), bufferWritermap, fileNameDtls.get(fileName), tempForm ,loopBack,fileName,isFileDateLogged,readerDao);
												temp_SubTempId_ElementValues = null;
												tempForm = null;
												drElementValues.clear();
												next5Flag = false;
											}
											//Store Element Values of Current Line Only
											temp_SubTempId_ElementValues = performKeyBasedDataElementValidation(drLine, fileName,inputForm,  currentTempForm, tempId_subTempId,columnIds,drElementValues,tranCodeMap);
											if(temp_SubTempId_ElementValues != null)
												drElementValues = (List<String>)temp_SubTempId_ElementValues.get(1);
											
											next2TempString.setLength(0);
										}
										
										fixedFormatFlag = true; // it is updated to true once it completed execution in this Fixed loop

									} else if(keyBasedDr.getParentChildIndicator().equals("C")){ // Logic For Child Transaction
										// Check Whether this Record Is Child Of Last Parent Record
										if(keyBasedDr.getParentKey().equals(parent)){
											// containsnext logic is added by Mohan Raj.V to check for contains and need to read next line on 30-03-18
											if( keyBasedDr.getStrIdentifier().equalsIgnoreCase("next") || keyBasedDr.getStrIdentifier().equalsIgnoreCase("containsNext") ){
												nextFlagTempForm = currentTempForm;
												nextFlag = true;
											} else if( keyBasedDr.getStrIdentifier().equalsIgnoreCase("next_2") ) {  // Added by Mohan Raj.V for KeyBased Changes (next-2)
												nextFlagTempForm = currentTempForm;
												nextFlag = true;
												next2Flag = true;
												//next2TempString = drLine;
											}else if(keyBasedDr.getStrIdentifier().equals("next_5")){  // added by vinoth
												
													if(!next5Flag) { 
														drLine = next2TempString.append(bufferReader.readLine()).append(bufferReader.readLine()).append(bufferReader.readLine()).append(bufferReader.readLine()).append(bufferReader.readLine()).toString();
														temp_SubTempId_ElementValues = performKeyBasedDataElementValidation(drLine, fileName, inputForm, currentTempForm, tempId_subTempId, columnIds, drElementValues, tranCodeMap);
														next5Flag = true;
														next2TempString.setLength(0);
													}else{
														
														if(drElementValues.get(Integer.parseInt(columnIds.split(",")[0])) == ""){ //check already 
															drLine = next2TempString.append(bufferReader.readLine()).append(bufferReader.readLine()).append(bufferReader.readLine()).append(bufferReader.readLine()).append(bufferReader.readLine()).toString();
															temp_SubTempId_ElementValues = performKeyBasedDataElementValidation(drLine, fileName, inputForm, currentTempForm, tempId_subTempId, columnIds, drElementValues, tranCodeMap);
															next2TempString.setLength(0);
														}else {
															drLine = bufferReader.readLine();
															continue;
														}
													}
												
											}else if( keyBasedDr.getStrIdentifier().equalsIgnoreCase("skipr")){
												temp_SubTempId_ElementValues = null;
												drElementValues.clear();
												parent = "";
											}  else if( keyBasedDr.getStrIdentifier().equalsIgnoreCase("end") ) { 
												// end will stop the current transaction and will write into dat File added by Mohan Raj.V on 07-02-16 
												if( temp_SubTempId_ElementValues != null ){
													//commented by Mohan ..need to test this value date logic for advisory since its affecting EJ and other logic
//													temp_SubTempId_ElementValues = performKeyBasedDataElementValidation(drLine, fileName, inputForm, currentTempForm, tempId_subTempId, columnIds, drElementValues, tranCodeMap);//Added for issue id - 54364 by Archana.J
													drElementValues = (List<String>)temp_SubTempId_ElementValues.get(1);
														if( invalidInputValidation((List<String>)temp_SubTempId_ElementValues.get(1) , templateConfigMap, currentTempForm,drLine) ) // Added by Mohan Raj.V on 16/03/16 for mandatory check validation
															isFileDateLogged = SplitData((List<String>)temp_SubTempId_ElementValues.get(1), temp_SubTempId_ElementValues.get(0).toString(), bufferWritermap, fileNameDtls.get(fileName), currentTempForm ,loopBack,fileName,isFileDateLogged,readerDao);
													temp_SubTempId_ElementValues = null;
													drElementValues.clear();
													parent = "";
												}
											}else if ( keyBasedDr.getStrIdentifier().equals("fixed") ) {
												 //added by Mohan Raj to read Advisory File (this logic will read all the line TILL it Find End Identifier) 
												String parent_tempId_subTempId = tempId_subTempId ;
												drLine = bufferReader.readLine();
												int lineNumber = 1;
												boolean recordFinished = false;
												while(drLine != null){
													
//													tempId_subTempId = findTemplate(drLine, inputForm);
													temp_tempId = findTemplate(drLine, inputForm, previousParent);
													tempId_subTempId = temp_tempId.split("~")[0];
													 keyBasedDr = DRInfoForKeyBased (drLine, drIdyMap,tempId_subTempId);
													 if(keyBasedDr != null && ! "".equals( keyBasedDr.getKey() ) && recordFinished){
														 if(keyBasedDr.getStrIdentifier().equals("end")){
															 if( drLine.contains(keyBasedDr.getKey())){
																 fixedFormatFlag = false;
															 }
														 }
													 }
													if(!drLine.trim().isEmpty() && fixedFormatFlag ){ // if not empty line
														if(drLine.substring(0,3).trim().matches("\\d+")) { 
															if(lineNumber == Integer.parseInt(drLine.substring(0,3).trim())) {
																if (parent_tempId_subTempId != null && !(parent_tempId_subTempId.equals(""))) {
																	 currentTempForm = templateConfigMap.get(parent_tempId_subTempId);																 															
																	 if(mergeAndFixedValuesList.size() > 0) {																		
																		 for(List<String> mergedrElement : mergeAndFixedValuesList ) {
																			 performKeyBasedDataElementValidation(drLine, fileName, inputForm, currentTempForm, parent_tempId_subTempId, columnIds, mergedrElement, tranCodeMap);
																			 SplitData(mergedrElement, parent_tempId_subTempId, bufferWritermap,fileNameDtls.get(fileName), currentTempForm,loopBack,fileName,isFileDateLogged,readerDao);
																			 mergeAndFixedValuesList.remove(mergedrElement);
																			 break;
																		 }	
																		 
																		 if(mergeAndFixedValuesList.size() == 0)
																			 recordFinished=true;
																	 }												
																}
																lineNumber++;
															}
														}
													}
													if( fixedFormatFlag ) {
														drLine = bufferReader.readLine();
													} else {
														drLine = null;
													}
												}
												
												fixedFormatFlag = true;
											}else if ( keyBasedDr.getStrIdentifier().equals("mergeAndFixed") ) {
												 //added by Mohan Raj to read Advisory File (this logic will read all the line TILL it Find End Identifier) 
												String parent_tempId_subTempId = tempId_subTempId ;
												drLine = bufferReader.readLine();
												
												while(drLine != null){
													
//													tempId_subTempId = findTemplate(drLine, inputForm);
													temp_tempId = findTemplate(drLine, inputForm, previousParent);
													tempId_subTempId = temp_tempId.split("~")[0];
													 keyBasedDr = DRInfoForKeyBased (drLine, drIdyMap,tempId_subTempId);
													 if(keyBasedDr != null && ! "".equals( keyBasedDr.getKey() )){
														 if(keyBasedDr.getStrIdentifier().equals("end")){
															 if( drLine.contains(keyBasedDr.getKey())){
																 fixedFormatFlag = false;
															 }
														 }
													 }
													if(!drLine.trim().isEmpty() && fixedFormatFlag ){ // if not empty line
														if (parent_tempId_subTempId != null && !(parent_tempId_subTempId.equals(""))) {
															 currentTempForm = templateConfigMap.get(parent_tempId_subTempId);	
															 List<String> mergeAndFixedValues = new ArrayList<String>();
															 mergeAndFixedValues.addAll(mergedrElementValues);
															 performKeyBasedDataElementValidation(drLine, fileName, inputForm, currentTempForm, parent_tempId_subTempId, columnIds, mergeAndFixedValues, tranCodeMap);
															 mergeAndFixedValuesList.add(mergeAndFixedValues);
															 
														}
													}
													if( fixedFormatFlag ) {
														drLine = bufferReader.readLine();
													} else {
														drLine = null;
													}
												}
												
												fixedFormatFlag = true;
											}else if("merge".equals(keyBasedDr.getStrIdentifier())){
												performKeyBasedDataElementValidation(drLine, fileName,inputForm,  currentTempForm, tempId_subTempId,columnIds,mergedrElementValues,tranCodeMap);
											
											}else if(!(keyBasedDr.getStrIdentifier().equalsIgnoreCase("skip")) && !"merge".equals(keyBasedDr.getStrIdentifier())){//Not Skip Record Continue reading for further child 
												//Store Element Values of Current Line as well as its Parent and child record prior to this
												temp_SubTempId_ElementValues = performKeyBasedDataElementValidation(drLine,fileName, inputForm,  currentTempForm, tempId_subTempId, columnIds,drElementValues,tranCodeMap);
												if(temp_SubTempId_ElementValues != null)
													drElementValues = (List<String>)temp_SubTempId_ElementValues.get(1);
												    
											}else { //  If SKIP record found, then Stop reading  further child record but write in dat file
	
													if( temp_SubTempId_ElementValues != null ){
	
													drElementValues = (List<String>)temp_SubTempId_ElementValues.get(1);
														if( invalidInputValidation((List<String>)temp_SubTempId_ElementValues.get(1) , templateConfigMap, currentTempForm,drLine) ) // Added by Mohan Raj.V on 16/03/16 for mandatory check validation
															isFileDateLogged = SplitData((List<String>)temp_SubTempId_ElementValues.get(1), temp_SubTempId_ElementValues.get(0).toString(), bufferWritermap, fileNameDtls.get(fileName), currentTempForm ,loopBack,fileName,isFileDateLogged,readerDao);
													temp_SubTempId_ElementValues = null;
													drElementValues.clear();
													parent = "";
											}
										}
									}
								}
							}
							}
						} else{
							// Modified by Mohan Raj.V on 14/03/16
							if(!next2Flag && nextFlag){
							temp_SubTempId_ElementValues = performKeyBasedDataElementValidation(drLine,fileName, inputForm,  nextFlagTempForm, tempId_subTempId, columnIds,drElementValues,tranCodeMap);
							if(temp_SubTempId_ElementValues != null)
								drElementValues = (List<String>)temp_SubTempId_ElementValues.get(1);
							nextFlag = false;
							}else if(next2Flag){
								if(!(("").equals(next2TempString.toString()))){
									next2TempString =next2TempString.append(drLine).append(" ");
									temp_SubTempId_ElementValues = performKeyBasedDataElementValidation(next2TempString.toString(),fileName, inputForm,  nextFlagTempForm, tempId_subTempId, columnIds,drElementValues,tranCodeMap);
									if(temp_SubTempId_ElementValues != null)
										drElementValues = (List<String>)temp_SubTempId_ElementValues.get(1);
									next2Flag = false;
									nextFlag = false;
									next2TempString =new StringBuffer("");
								}else{
									next2TempString = new StringBuffer("");
									next2TempString =next2TempString.append(drLine).append(" ");
								}
							}
							/*int count = 0 ;
							if( next2Flag ) {
								if( count == 0 )
									tempDrElementValues = drElementValues;
								if( count == 1 )
									drElementValues = tempDrElementValues + drElementValues; 
									next2Flag =false;
								}
							count++;*/
						}
						}
							drLine = bufferReader.readLine();	
						}
					
						if(KeyCache.doesKeyExist(inputForm.getInstitutionCode())) KeyCache.removeKey(inputForm.getInstitutionCode());  //Added by vinoth
					
						// To write Last Transaction( Including Parent and Child) in DAT File
						if(temp_SubTempId_ElementValues != null){

							drElementValues = (List<String>)temp_SubTempId_ElementValues.get(1);
							if( invalidInputValidation((List<String>)temp_SubTempId_ElementValues.get(1) , templateConfigMap, currentTempForm,drLine) ) // Added by Mohan Raj.V on 16/03/16 for mandatory check validation
							isFileDateLogged = SplitData((List<String>)temp_SubTempId_ElementValues.get(1), temp_SubTempId_ElementValues.get(0).toString(), bufferWritermap, fileNameDtls.get(fileName), currentTempForm,loopBack,fileName,isFileDateLogged,readerDao);
							temp_SubTempId_ElementValues = null;
							drElementValues.clear();
						} 
						//commented by Mohan Raj.V to resolve the issue while reading Fixed format in keybased
						/*else{
							logger.info("In Key Based unable to write the last record in dat File");
							throw new ReconUserDefinedException("In Key Based unable to write the last record in dat File");
						}*/
					
				} else if(inputForm.getDataFormat() != null && inputForm.getDataFormat().equalsIgnoreCase("V")) {

					logger.debug("in variable based file read() ");
					footerStatus = readVariableBasedFile(fileName, inputForm, bufferWritermap, templateConfigMap,loopBack, fileNameDtls);
					//if(KeyCache.doesKeyExist(inputForm.getInstitutionCode())) KeyCache.removeKey(inputForm.getInstitutionCode());  //commented by Mohan , have to move this logic to controller (benchmarking)
				}

				//to close all writer objects.
				for(BufferedWriter bw : bufferWritermap.values()) {
					if(bw != null )
						bw.close();
				}
				
				if (inputForm.getFooterAvailable().equalsIgnoreCase((ReconConstants.CHECK_FLAG_YES))) {
					if(!footerStatus){
						logger.error("Footer is Configured but File don't have Footer ");
						throw new ReconUserDefinedException("No Footer Found for the file : "+fileName);
					}
				}
				
				terminalId = ""; // empty the global value  once the file is extracted  by mohan raj.v
				
				// Logic to execute the DAT file using sql loader
				callSqlLoader(fileName, templateConfigMap, filePath, loopBack, readerDao);  
				//Added by MOhan Raj To call Merge Procedure for Advisory File
				String templateTypeDesc = "" ; 
				boolean procStatus  =false;
				for(Map.Entry<String, TemplateForm>temp : templateConfigMap.entrySet()) {
					String tempId = temp.getKey();
					TemplateForm templateForm = temp.getValue();
					templateTypeDesc = templateForm.getTemplateTypeDesc();
				}
				if( "ADVISORY_TEMP".equalsIgnoreCase( templateTypeDesc ) ) { 
					procStatus = 	readerDao.callMergingProcedure( inputForm.getFileId() , loopBack ) ;
					
					if( ! procStatus ) {
						logger.error("Exception Occured in SP_ADVISORY_MERGE ");
						
					}
				}
				
			}
		} catch (ReconUserDefinedException e) {
			logger.error("ReconException occured in readFile() " , e);
			throw new ReconUserDefinedException(e.getMessage());
		} catch (Exception e) {
			logger.error("Exception occured in readFile() " , e);
			throw new ReconUserDefinedException("Exception Occured while Reading the file name : " + fileName + " " + e);
		} finally {
			calculatedValues.clear();
			try {
				if (bufferWritermap != null) {
					
					for(BufferedWriter bufferedWriter: bufferWritermap.values())  // added by vinoth for close resource - 14-03-2017
						 bufferedWriter.close();
					
					bufferWritermap.clear();
					bufferWritermap = null;
				}

				if (bufferReader != null)
					bufferReader.close();
			} catch (Exception e) {
				logger.error("Exception occured while closing objects " + e);
			}
		}
	}
	
	/***
	 * Added by vinoth - Merging key based with fixed
	 * 
	 * @author vinothkumarm
	 * */
	
	
	

	public InputFileReaderDao getReaderDao() {
		return readerDao;
	}

	public void setReaderDao(InputFileReaderDao readerDao) {
		this.readerDao = readerDao;
	}

	public HeaderValidation getHeaderValidation() {
		return headerValidation;
	}

	public void setHeaderValidation(HeaderValidation headerValidation) {
		this.headerValidation = headerValidation;
	}

	public FooterValidation getFooterValidation() {
		return footerValidation;
	}

	public void setFooterValidation(FooterValidation footerValidation) {
		this.footerValidation = footerValidation;
	}

	/*public AutowireCapableBeanFactory getBeanFactory() {
		return beanFactory;
	}

	public void setBeanFactory(AutowireCapableBeanFactory beanFactory) {
		this.beanFactory = beanFactory;
	}*/

	
}
