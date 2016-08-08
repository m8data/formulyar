<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common">
	<xsl:param name="params_of_quest" select="document( concat( $questID, '/', $author, '/', $avatar, '/', $quest, '/port.xml' ) )/*/*"/>
	<xsl:param name="action_types" select="document( '/m8/r1/_/index.xml' )/*/predicate/*"/>
	<!--

	-->
	<xsl:template match="port" mode="start">
		<xsl:choose>
			<xsl:when test="$questID">
				<xsl:choose>
					<xsl:when test="document( concat( $questID, '/index.xml' ) )/*/role/role1">
						<xsl:message>Зеленая карта</xsl:message>
						<div style="margin: 2em; padding: 1em; background: #EFD">
							<div style="float: right">
								<a href="{concat( '/m8/', $params_of_quest[name()='_']/*/@type, '/', name($params_of_quest[name()='_']/*) ) }">X</a>
							</div>
							<xsl:apply-templates select="document( concat( $questID, '/', $author, '/', $avatar, '/', $quest, '/port.xml' ) )/*" mode="quest_port"/>
							<br style="clear: both"/>
						</div>
					</xsl:when>
					<xsl:when test="$action_types[name()=$quest]">
						<xsl:message>Красная карта</xsl:message>
						<div style="margin: 2em; padding: 1em; background: #FED">
							<div style="float: right">
								<a href="/">X</a>
							</div>
							<b>Выбор объекта "<xsl:value-of select="$quest"/>"</b>
							<div style="padding: 1em">
								<xsl:for-each select="document( concat( '/m8/r1/_/', $quest,  '.xml' ) )/*/*[name()=$author]/*[name()=$avatar]/*">
									<div>
										<a href="/m8/{@type}/{name()}">
											<xsl:apply-templates select="." mode="titleWord"/>
										</a>
									</div>
								</xsl:for-each>
							</div>
							<div style="position: absolute; bottom: 50px; right: 50px; font-size: 2em">
								<a href="/m8/?_={$quest}">+</a>
							</div>
							<br style="clear: both"/>
						</div>
					</xsl:when>
					<xsl:otherwise>Не сконструировано</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<div style="padding: 1em">
							Выбор типа задачи
							<xsl:for-each select="$action_types">
						<div>
							<a href="/m8/r0/{name()}">
								<xsl:value-of select="name()"/>
							</a>
						</div>
					</xsl:for-each>
					<div style="position: absolute; bottom: 50px; right: 50px; font-size: 2em">
						<form name="type" method="get" action="/m8">
							<input type="text" name="_"/>
							<input type="submit" value="создать и перейти"/>
						</form>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template match="port" mode="quest_port">
		<xsl:variable name="typeName" select="name(_/*)"/>
		<div>
			<b>
				<xsl:value-of select="$typeName"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="substring( $questID, 8 )"/>
			</b>
		</div>
		<div style="clear: both"/>
		<xsl:variable name="predicates">
			<xsl:for-each select="document( concat( '/m8/r1/_/', $typeName, '.xml' ) )/*/*/*/*">
				<xsl:variable name="qName" select="name()"/>
				<xsl:variable name="sovpadenie">
					<xsl:if test="name()!=$quest">
						<xsl:for-each select="document( concat( '/m8/', @type, '/', $qName, '/', $author, '/', $avatar, '/', $qName, '/port.xml' ) )/*/*/*">
							<xsl:variable name="siblingName" select="name(..)"/>
							<xsl:variable name="siblingValue" select="name()"/>
							<xsl:if test="$params_of_quest[name()=$siblingName]/*[name()=$siblingValue]">
								<xsl:element name="sibling"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:variable>
				<xsl:variable name="sovpadenie_count" select="count(exsl:node-set($sovpadenie)//*)"/>
				<!--<code id="11111111111">
					<xsl:copy-of select="exsl:node-set($sovpadenie)"/>
				</code>-->
				<xsl:for-each select="document( concat( '/m8/n0/', $qName, '/', $author, '/', $avatar, '/', $qName, '/port.xml' ) )/*/*[name()!='_']">
					<xsl:variable name="pName" select="name()"/>
					<xsl:element name="{$pName}">
						<xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
						<!--<xsl:if test="$qName != $quest">-->
							<xsl:for-each select="*">
								<xsl:variable name="pValue" select="name()"/>
								<!--<xsl:if test="not($params_of_quest[name()=$pName]/*[name()=$pValue])">-->
									<xsl:element name="{name()}">
										<xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
										<xsl:attribute name="sovpadenie"><xsl:value-of select="$sovpadenie_count"/></xsl:attribute>
									</xsl:element>
								<!--</xsl:if>-->
							</xsl:for-each>
						<!--</xsl:if>-->
					</xsl:element>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<code id="1">
			<xsl:copy-of select="exsl:node-set($predicates)"/>
		</code>
		<xsl:variable name="sorted_predicates">
			<xsl:for-each select="exsl:node-set($predicates)/*">
				<xsl:sort select="name()"/>
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<code id="2">
			<xsl:copy-of select="exsl:node-set($sorted_predicates)"/>
		</code>
		<xsl:variable name="sorted_and_grouped">
			<xsl:apply-templates select="exsl:node-set($sorted_predicates)/*[1]" mode="predicate_grouping"/>
		</xsl:variable>
		<code id="3">
			<xsl:copy-of select="exsl:node-set($sorted_and_grouped)"/>
		</code>
		<xsl:variable name="final_sort">
			<xsl:for-each select="exsl:node-set($sorted_and_grouped)/*">
				<xsl:element name="{name()}">
					<xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
					<xsl:attribute name="count"><xsl:value-of select="@count"/></xsl:attribute>
					<xsl:apply-templates select="*[1]" mode="value_grouping"/>
				</xsl:element>
				<!--<predicate name="{@name}" count="{@count}">
						<xsl:apply-templates select="*[1]" mode="value_grouping"/>
					</predicate>-->
			</xsl:for-each>
		</xsl:variable>
		<code id="4">
			<xsl:copy-of select="exsl:node-set($final_sort)"/>
		</code>
		<div style="padding: 1em; margin: .5em; float: left; width: 30%">
			<table>
				<xsl:for-each select="exsl:node-set($final_sort)/*">
					<xsl:sort select="name()"/>
					<xsl:variable name="pName" select="name()"/>
					<tr>
						<th valign="top" align="right">
							<span style="font-size: .7em">
								<xsl:value-of select="$pName"/>
							</span>
						</th>
						<th align="left">
							<xsl:for-each select="$params_of_quest[name()=$pName]/*">
								<xsl:variable name="pValueName" select="name()"/>
								<xsl:call-template name="editParamOfPort">
									<xsl:with-param name="predicateName" select="$pName"/>
									<xsl:with-param name="refList" select="$final_sort"/>
									<xsl:with-param name="selectedName" select="$params_of_quest[name()=$pName]/*[name()=$pValueName]"/>
								</xsl:call-template>
							</xsl:for-each>
						</th>
					</tr>
				</xsl:for-each>
			</table>
		</div>
		<div style="padding: 1em; float: right; width: 60% ">
			<!--<xsl:variable name="params_of_quest" select="/*/*/@*[name() != 'type' ]"/>-->
			<!--<xsl:value-of select="$predicates"/>-->
			<xsl:for-each select="exsl:node-set($final_sort)/*">
				<xsl:variable name="predicate" select="name()"/>
				<!--<xsl:if test="not($params_of_quest[name()=$predicate]) or *">-->
				<div style="padding: .1em">
					<a href="{$questID}/?a2={$predicate}" title="популярность: {@count}">
						<xsl:value-of select="name()"/>
					</a>
					<xsl:if test="*">
						<xsl:text>: </xsl:text>
						<xsl:for-each select="*">
							<span style="font-size: 1.{@sovpadenie}em" title="контекстов - {@sovpadenie}, упоминаний - {@count}">
								<!--<xsl:if test="*/*[@name="-->
								<a href="{$questID}/?a2={$predicate}&amp;a3={name()}">
									<xsl:apply-templates select="." mode="titleWord"/>
								</a>
								<!--<sup>
									<xsl:value-of select="@count"/>
									<a href="/m8/{@type}/{name()}">*</a>
								</sup>-->
							</span>
							<xsl:text>  </xsl:text>
						</xsl:for-each>
					</xsl:if>
				</div>
				<!--</xsl:if>-->
			</xsl:for-each>
			<br/>
						Добавление параметра
			<form action="{$questID}/">
				<input type="text" name="a2"/>
				<input type="hidden" name="a3" value="null"/>
				<input type="submit" value="+"/>
			</form>
			<!--<xsl:choose>
							<xsl:when test="/*/*/@focus">
								<form name="type" method="get" action="{$questID}/">
									<input type="text" name="type"/>
									<input type="submit" value="+"/>
								</form>
							</xsl:when>
							<xsl:otherwise>
								
								
							</xsl:otherwise>
						</xsl:choose>-->
		</div>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="predicate_grouping">
		<xsl:variable name="predicate" select="name()"/>
		<xsl:variable name="ref_with_this_predicate" select="../*[name() = $predicate]"/>
		<xsl:variable name="summ_sovp" select="../*[name() = $predicate]"/>
		<!--<xsl:variable name="value_with_this_predicate" select="../ref[@predicate = $predicate]/value"/> //-->
		<xsl:element name="{$predicate}">
			<xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_predicate)"/></xsl:attribute>
			<xsl:for-each select="$ref_with_this_predicate">
				<xsl:for-each select="*">
					<xsl:sort select="name()"/>
					<xsl:element name="{name()}">
						<xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
						<xsl:attribute name="sovpadenie"><xsl:value-of select="@sovpadenie"/></xsl:attribute>
					</xsl:element>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:element>
		<!--
    Входящий список в $sorted_plain отсортирован,
    поэтому в следующую группу отправляем элемент,
    идущий за последним элементом в текущей группе
    -->
		<xsl:apply-templates select="$ref_with_this_predicate[last()]/following-sibling::*[1]" mode="predicate_grouping"/>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="value_grouping">
		<xsl:variable name="value" select="name()"/>
		<xsl:variable name="ref_with_this_value" select="../*[name() = $value]"/>
		<xsl:variable name="ref_with_this_value_sum_sovp" select="sum(../*[name() = $value]/@sovpadenie)"/>
		<!--<xsl:variable name="value_with_this_predicate" select="../ref[@predicate = $predicate]/value"/> //-->
		<xsl:element name="{$value}">
			<xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_value)"/></xsl:attribute>
			<xsl:attribute name="sovpadenie"><xsl:value-of select="$ref_with_this_value_sum_sovp"/></xsl:attribute>
		</xsl:element>
		<xsl:apply-templates select="$ref_with_this_value[last()]/following-sibling::*[1]" mode="value_grouping"/>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="titleWord">
		<xsl:choose>
			<xsl:when test="@type = 'n1' and starts-with( name(), 'l' )">
				<xsl:value-of select="substring( document ( concat( '/m8/n1/', name(), '/value.xml' ) )/*, 0, 70 )"/>
			</xsl:when>
			<xsl:when test="@type = 'r1'">
				<xsl:value-of select="substring-after( name(), '_' )"/>
			</xsl:when>
			<xsl:when test="document ( concat( '/m8/', @type, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' ) )/*/name">
				<xsl:message>Попытка найти имя в потру текущего автора</xsl:message>
				<xsl:apply-templates select="document ( concat( '/m8/', @type, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' ) )/*/name/*" mode="titleWord"/>
				<!--	<xsl:variable name="nameValueFromPort" select="name( document ( concat( '/m8/', @type, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' ) )/*/name/* )"/>
				<xsl:choose>
					<xsl:when test="starts-with( $nameValueFromPort, 'l' )"><xsl:value-of select="document ( concat( '/m8/n1/', $nameValueFromPort, '/value.xml' ) )/*"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$nameValueFromPort"/></xsl:otherwise>
				</xsl:choose>-->
			</xsl:when>
			<xsl:when test="document ( concat( '/m8/', @type, '/', name(), '/', $avatar, '/', $avatar, '/', name(), '/port.xml' ) )/*/name">
				<xsl:message>Попытка найти имя в потру аватар-автора</xsl:message>
				<xsl:apply-templates select="document ( concat( '/m8/', @type, '/', name(), '/', $avatar, '/', $avatar, '/', name(), '/port.xml' ) )/*/name/*" mode="titleWord"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="name()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template name="editParamOfPort">
		<xsl:param name="inputType"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedName"/>
		<xsl:param name="refList"/>
		<xsl:param name="sourceValue"/>
		<!--<xsl:variable name="predicateName" select="name()"/> style="padding: .8em"-->
		<form action="{$questID}/?">
			<!--<input type="text" value="{name()}"/>-->
			<xsl:choose>
				<xsl:when test="$sourceValue">
					<!--<xsl:for-each select="exsl:node-set($sourceValue)/*"><div>[<xsl:value-of select="."/>]</div></xsl:for-each>-->
					<xsl:call-template name="inputParamOfPort">
						<xsl:with-param name="inputType" select="$inputType"/>
						<xsl:with-param name="predicateName" select="$predicateName"/>
						<xsl:with-param name="selectedName" select="$selectedName"/>
						<xsl:with-param name="refList" select="$refList"/>
						<xsl:with-param name="sourceValue" select="$sourceValue"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$action_types[name()=$predicateName]">
					<xsl:call-template name="inputParamOfPort">
						<xsl:with-param name="inputType" select="$inputType"/>
						<xsl:with-param name="predicateName" select="$predicateName"/>
						<xsl:with-param name="selectedName" select="$selectedName"/>
						<xsl:with-param name="refList" select="$refList"/>
						<xsl:with-param name="sourceValue" select="document( concat( '/m8/r1/_/', $predicateName, '.xml' ) )/*/*/*"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="inputParamOfPort">
						<xsl:with-param name="inputType" select="$inputType"/>
						<xsl:with-param name="predicateName" select="$predicateName"/>
						<xsl:with-param name="selectedName" select="$selectedName"/>
						<xsl:with-param name="refList" select="$refList"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</form>
	</xsl:template>
	<!--

	-->
	<xsl:template name="inputParamOfPort">
		<xsl:param name="inputType"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedName"/>
		<xsl:param name="refList"/>
		<xsl:param name="sourceValue"/>
		<!--<xsl:variable name="predicateValues" select="//*[name()=$predicateName]/*"/>
		Здесь можно былоо бы указать /*/*[name()=$predicateName] для порта, эти шаблон можно попытаться применить и для других случаев -->
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<th>
					<xsl:if test="$sourceValue">
						
					
					</xsl:if>
				
				</th>
				<th></th>
			</tr>
		</table>

		<xsl:choose>
			<xsl:when test="$inputType">
				<xsl:for-each select="exsl:node-set($sourceValue)/*">
					<input onchange="this.form.submit()" type="{$inputType}" name="{$selectedName}" value="{name()}">
						<xsl:if test="name()=name($selectedName)">
							<xsl:attribute name="checked"><xsl:value-of select="'checked'"/></xsl:attribute>
						</xsl:if>
					</input>
					<xsl:apply-templates select="." mode="titleWord"/>
					<br/>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="exsl:node-set($sourceValue)/*[2]">
				<select onchange="this.form.submit()" name="{$predicateName}">
					<option/>
					<xsl:for-each select="exsl:node-set($sourceValue)/*">
						<xsl:variable name="valueName" select="name()"/>
						<option value="{name()}">
							<xsl:if test="name()=name($selectedName)">
								<xsl:attribute name="selected"><xsl:value-of select="'selected'"/></xsl:attribute>
							</xsl:if>
							<xsl:apply-templates select="." mode="titleWord"/>
							<xsl:if test="$refList[name()=$valueName]">
								<xsl:text> - </xsl:text>
								<xsl:value-of select="$refList[name()=$valueName]/@sovpadenie"/>
							</xsl:if>
							<!--<xsl:apply-templates select="document( concat( '/m8/n0/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml') )/*/имя/*" mode="titleWord"/>-->
						</option>
					</xsl:for-each>
				</select>
			</xsl:when>
			<xsl:otherwise>
				<!--<xsl:value-of select="$predicateValues[1]"/>-->
				<input type="text" name="{name()}">
					<xsl:attribute name="value"><xsl:apply-templates select="$selectedName" mode="titleWord"/></xsl:attribute>
				</input>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
</xsl:stylesheet>
