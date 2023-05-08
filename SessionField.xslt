<?xml version="1.0" encoding= "UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<html>
			<body>
				<h2>Policy Details</h2>
				<table border="1">
					<tr bgcolor="#b3cbff">
						<th>
							policyID
						</th>
						<th>
							CompanyNAICCdCode
						</th>
						<th>
							AgentPrefix
						</th>
						<th>
							BMTCode
						</th>
						<th>
							SICCode
						</th>
						<th>
							RateRevisionVersionNbr
						</th>
						<th>
							AgentCode
						</th>
						<th>
							Channel
						</th>
						<th>
							RatedMarketCalculation
						</th>
						<th>
							PolicyNumber
						</th>
						<th>
							ProductCalculation
						</th>
						<th>
							RenewalCounter
						</th>
						<th>TierAssignment</th>
						<th>AverageDriverSurcharge</th>
					</tr>
					<tr>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/policy/policyProcessing/CurrentPolicyNumberIdentifier"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/account/BMTCode"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/account/SICCode"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/policy/RatedMarketCalculation"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getA11DocumentsRs/session/data/policy/ProductCalculation"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/policy/CompanyNAICCdCode"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/policy/line/RateRevisionVersionNbr"/>
						</td>
						<td>
							<xsl:value-of select="/server/ responses/Session.getA11DocumentsRs/session/data/policy/PolicyNumber"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/policy/RenewalCounter"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/agencyinfo/AgentCodePrefix"/>
						</td>
						<td>
							<xsl:value-of  select="/server/responses/Session.getAllDocumentsRs/session/data/agencyinfo/AgentCode"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/account/Channel"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/account/CurrentTier"/>
						</td>
						<td>
							<xsl:value-of select="/server/responses/Session.getAllDocumentsRs/session/data/account/AverageDriverSurcharge"/>
						</td>

					</tr>
				</table>
				<xsl:text> </xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<h2>Policy Coverages=""</h2>
				<table border="1">
					<tr bgcolor="#b3ebff">
						=""
						<th style="text-align:left">Indicator</th>
						<th style="text-align:left">LCL</th>
						<th style="text-align:left">Limit</th>
						<th style="tex-align:left">Selected</th>
						<th style="text-align:left">Type</th>
						<th style="text-align:left">Deductible</th>
						<th style="text-align:left">Premium</th>
						<th style="text-align:left">Change</th>
						<th style="text-align:left">ChangeForCorpBilling</th>
					</tr>
					<xsl:for-each select="/server/responses/Session.getAllDocumentsRs/session/data/policy/line/coverage">
						<tr>
							<td>
								<td>
								</td>
								<td>
									<td>
										<td>
										</td>
									</td>
								</td>
							</td>
							<td>
								<td>
									<td>
										<td>
											<xsl:value-of select= "Indicator"/>
											<xsl:value-of select="LCL"/>
											<xsl:value-of select="Limit"/>
											<xsl:value-of select="Selected"/>
											<xsl:value-of select= "Type"/>
											<xsl:value-of select= "Deductible"/>
										</td>
										<xsl:value-of select="Premium"/>
									</td>
									<xsl:value-of select="change"/>
								</td>
								<xsl:value-of select= "PremiumChangeforCorpBilling"/>
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<xsl:text> </xsl:text>
				<xsl:text>=""&#xa;</xsl:text>
				<h2>
					Additional Insured Details
				</h2>
				<table border="1">
					<tr becolor="#b3cbff">
						<th style="text-align:left" >Name</th>
						<th style="text-align:left">Type</th>
						<th style="text-align:left">Address</th>
						<th style="text-align:left">State</th>
						<th style="text-align:left">City</th>
						<th style="text-align:left">ZipCode</th>
					</tr>
					<xsl:for-each select="/server/responses/Session.getAllDocumentss/session/data/account/additionalotherinterest">
						<tr>
							<td>
								<xsl:value-of select= "Name"/>
							</td>
							<td>
								<xsl:value-of select= "Type"/>
							</td>
							<td>
								<xsl:value-of select="address/Address"/>
							</td>
							<td>
								<xsl:value-of select="address/City"/>
							</td>
							<td>
								<xsl:value-of select="address/State"/>
							</td>
							<td>
								<xsl:value-of select="address/ZipCode"/>
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<xsl:text> </xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<h2>Driver Details</h2>
				<table border="1">
					<tr bgcolor="#b3cbff">
						<th style="text-align:left">DriverPositionNbr=""</th>
						<th style="text-align:left">
							FirstName
						</th>
						<th style="text-align:left">
							LastName
						</th>
						<th style="text-align:left">DateofBirth</th>
						<th style="text-align:left">
							AgeOfDriver
						</th>
						<th style="text-align:left">
							DriverAddedDate=""
						</th>
						<th style="text-align:left">DriverkeyNbr</th>
						<th style="text-align:left">
							DriverLicenseNumber
						</th>
						<th style="text-align:left">
							Licensestate
						</th>
						<th style="text-align:left">
							HasCDL
						</th>
						<th style="text-align:left">
							MVRStatusReturnedCode
						</th>
						<th style="text-align:left">
							AnyAccidentsViolationsPastThreeYears
						</th>
						<th style="text-align:left">
							DriverTotalViolationsPoints
						</th>
						<th style="text-align:left">Violations</th>
					</tr>
					<xsl:for-each select="/server/responses/Session.getAllDocumentsRs/session/data/account/driver">
						<tr>
							<td>
								<xsl:value-of select="DriverPositionNbr"/>
							</td>
							<td>
								<xsl:value-of select= "FirstName"/>
								<td>
									<xsl:value-of select= "LastName"/>
								</td>
							</td>
							<td>
								<xsl:value-of select="DateofBirth"/>
							</td>
							<td>
								<xsl:value-of select="AgeOfDriver"/>
							</td>
							<td>
								<xsl:value-of select= "DriverAddedDate"/>
							</td>
							<td>
								<xsl:value-of select="DriverKeyNbr"/>
							</td>
							<td>
								<xsl:value-of select= "DriverLicenseNumber"/>
							</td>
							<td>
								<xsl:value-of select="LicenseState"/>
							</td>
							<td>
								<xsl:value-of select="HasCDL"/>
							</td>
							<td>
								<xsl:value-of select="MVRStatusReturnedCode" />
							</td>
							<td>
								<xsl:value-of select="AnyAccidentsViolationsPastThreeYears"/>
							</td>
							<td>
								<xsl:value-of select= "DriverTotalviolationsPoints"/>
							</td>
							<td>
								<table border="1">
									<tr>
										<th style="text-align:left">
											AccidentsViolationsOutputTotalViolationsPoints
										</th>
										<th style="text-align:left">
											AccidentViolation
										</th>
										<th style= "text-align:left"> DateofIncident</th>
										<th style="text-align:left">
											SourceCode
										</th>
										<th style="text-align:left">UnknownViolationDateInd</th>
										<th style="text-align:left">DateofIncidentDup</th>
									</tr>
									<xsl:for-each select="accidentsviolations">
										<tr>

											<td>
												<xsl:value-of select="AccidentsViolationsOutputTotalViolationsPoints"/>

											</td>
											<td>
												<xsl:value-of select="AccidentViolation"/>
											</td>
											<xsl:value-of select="DateofIncident"/>
											<td>
											</td>
											<td>
												<xsl:value-of select= "SourceCode"/>
											</td>
											<td>
												<xsl:value-of select= "UnknownViolationDateInd"/>
											</td>
											<td>
												<xsl:value-of select= "Date0fIncidentDup"/>
											</td>
										</tr>
									</xsl:for-each>
								</table>
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<xsl:text> </xsl:text>
				<xsl:text>
				&#xa;
			</xsl:text>
				<h2>Vehicle Details</h2>
				<table border="1">
					<tr bgcolor="#b3cbff">
						<th style="text-align:left">
							VehiclePositionNbr
						</th>
						<th style="text-align:left">BodyCode</th>
						<th style="text-align:left">BodyStyle</th>
						<th style="text-align:left" >Body Type</th>
						<th style="text-align:left">OwnLeaseIndicator</th>
						<th style="text-align:left">RiskType</th>
						<th style="text-align:left">StatedAmount</th>
						<th style="text-align:left">UseClass</th>
						<th style="text-align:left">VIN</th>
						<th style="text-align:left">
							VehicleTypeCode
						</th>
						<th style="text-align:left">
							Year
						</th>
						<th style="text-align:left">
							PriorTermBodyType
						</th>
						<th style="text-align:left">
							Coverages
						</th>
					</tr>
					<xsl:for-each select="/server/responses/Session.getAllDocumentsRs/session/data/policy/line[Type='CommercialAuto']/risk">
						<tr>
							<td>
								<xsl:value-of select="VehiclePositionNbr"/>
							</td>
							<td>
								<xsl:value-of select= "BodyCode"/>
							</td>
							<td>
								<xsl:value-of select= "BodyStyle"/>
							</td>
							<td>
								<xsl:value-of select="BodyType"/>
							</td>
							<td>
								<xsl:value-of select= "OwnLeaseIndicator"/>
							</td>
							<td>
								<xsl:value-of select="RiskType"/>
							</td>

							<td>
								<xsl:value-of select="StatedAmount"/>
							</td>
							<td>
								<xsl:value-of select="UseClass"/>
							</td>
							<td>
								<xsl:value-of select="VIN"/>
							</td>
							<td>
								<xsl:value-of select= "VehicleTypeCode"/>
							</td>
							<td>
								<xsl:value-of select= "Year"/>
							</td>
							<td>
								<xsl:value-of select= "PriorTermBodyType"/>
							</td>
							<td>
								<table border="1">
									<tr>
										<th style= "text-align:left">Indicator</th>
										<th style="text-align:left">
											Limit
										</th>
										<th style="text-align:left">Type</th>
										<th style="text-align:left">Premium</th>
										<th style="text-align:left">LCL</th>
										<th style= "text-align:left">Selected</th>
										<th style="text-align:left">Deductible</th>
										<th style="text-align:left">Change</th>
										<th style="text-align:left" >
											ChangeForCorpBilling
										</th>
									</tr>
									<xsl:for-each select="coverage">
										<tr>
											<td>
												<xsl:value-of select="Indicator"/>
												<xsl:value-of select="LCL"/>
											</td>
											<td>
												<xsl:value-of select="Limit"/>
												<xsl:value-of select="Selected"/>
											</td>
											<td>
												<xsl:value-of select="Type"/>
												<xsl:value-of select="Deductible"/>
											</td>
											<td>
												<xsl:value-of select="Premium"/>
												<xsl:value-of select="change"/>
											</td>
											<td>
												<xsl:value-of select="PremiumChangeForCorpBilling"/>
											</td>
										</tr>
									</xsl:for-each>
								</table>
							</td>
						</tr>
					</xsl:for-each>
				</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>