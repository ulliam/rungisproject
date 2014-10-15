<%@ page language="java"   pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" >
		<link href="/SDDY/CSS/comm2.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="JS/comm.js"></script>
		<script type="text/javascript" src="My97DatePicker/WdatePicker.js"></script>
		<script type="text/javascript" src="/SDDY/JS/jquery-1.4.2.js"></script>
		<script src="maps/libs/SuperMap.Include.js"></script>
		<script type="text/javascript" src="jquery-easyui-1.3.2/jquery-1.8.0.min.js"></script>
		<script type="text/javascript" src="jquery-easyui-1.3.2/jquery.easyui.min.js"></script>
		<script type="text/javascript" src="jquery-easyui-1.3.2/locale/easyui-lang-zh_CN.js"></script>
		<link rel="stylesheet" type="text/css" href="jquery-easyui-1.3.2/themes/default/easyui.css"/>
		<link rel="stylesheet" type="text/css" href="jquery-easyui-1.3.2/themes/icon.css"/> 
	<script type="text/javascript">
  var map, layer, vectorLayer,drawPolygon, markerLayer,
		    style = {
                strokeColor: "#333333",
                strokeWidth: 2,
                pointerEvents: "visiblePainted",
                fillColor: "#304DBE",
                fillOpacity: 1				
            },
            stylered = {
                pointRadius: 1,
                strokeColor: "#FF0000",
				strokeOpacity: 1, 
                fillColor: "#FF0000",
                fillOpacity: 0.8		
            },
            styleyellow = {
                pointRadius: 1,
                stroke: true,
                strokeColor: "#FFFF00",
				strokeOpacity: 1, 
                fillColor: "#FFFF00",
                fillOpacity: 0.4				
            },
            styleorange = {
               	pointRadius: 1,
                strokeColor: "#FFA500",
				strokeOpacity: 1, 
                fillColor: "#FFA500",
                fillOpacity: 0.6				
            },
			 stylepuff = {
               pointRadius: 1,
                strokeColor: "#000000",
				strokeOpacity: 1, 
                fillColor: "#000000",
                fillOpacity: 1				
            };
		 // 设置访问的GIS服务地址
         var url = "${MAPSERVER}";
        
         function onPageLoad() {
			// 创建客户端矢量图层，用于显示绘制的几何对象
			vectorLayer = new SuperMap.Layer.Vector("Vector Layer");
            // 创建marks图层，显示查询结果
			markerLayer = new SuperMap.Layer.Markers("Markers");
			// 创建绘制面的控件
            drawPolygon = new SuperMap.Control.DrawFeature(vectorLayer, SuperMap.Handler.Polygon);     
            drawPolygon.events.on({"featureadded": drawPolygonCompleted});
			// 创建图层对象
			drawPoint = new SuperMap.Control.DrawFeature(vectorLayer, SuperMap.Handler.Point);     
            drawPoint.events.on({"featureadded": drawPointCompleted});
            layer = new SuperMap.Layer.TiledDynamicRESTLayer("dongying", url, {transparent: true, cacheEnabled: true}, {maxResolution:"auto"}); 
           
			//向map添加图层
			layer.events.on({"layerInitialized": addLayer}); 

			// 创建地图对象
           map = new SuperMap.Map("map",{
//            			 minScale:3.01761783100639e-5,
// 			        maxScale:4.828188529610221e-4,
// 			        restrictedExtent:new SuperMap.Bounds(529811.237195,4209035.387174,543167.126545,4222363.734167) ,
           			controls: [
                      new SuperMap.Control.LayerSwitcher(),
                      new SuperMap.Control.ScaleLine(),
                      new SuperMap.Control.PanZoomBar({showSlider:true}),
                      new SuperMap.Control.Navigation({
                          dragPanOptions: {
                              enableKinetic: true
                          }}),
                      drawPolygon]
            });
			// 加载鹰眼控件
            map.addControl(new SuperMap.Control.OverviewMap());
            map.addControl(drawPoint);
        }
		
		  function geo() { 
    // 设置关联的外部数据库信息,alias表示数据库别名 
   // 设置关联信息 
//     var joinItem = new SuperMap.REST.JoinItem({ 
//         foreignTableName: "tb_shuju", 
//         joinFilter:"tb_shuju.SMID=Aloha_Point.SMID",
// 		joinType:SuperMap.REST.JoinType.INNERJOIN
//     }); 
    // 设置查询参数，在查询参数中添加linkItem关联条件信息 
    var queryParam, queryBySQLParams, queryBySQLService; 
    queryParam = new SuperMap.REST.FilterParameter({ 
        name: "Aloha_Red_P@SDDY_GIS", 
        //attributeFilter: "tb_shuju.color='red'", 
        //attributeFilter: "SmID<7" ,
        fields: ["SmID","SMX","SMY"]
       // joinItems: [joinItem]
     }), 
    queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({ 
         queryParams: [queryParam] 
            }), 
    queryBySQLService = new SuperMap.REST.QueryBySQLService(url, { 
        eventListeners: { 
            "processCompleted": queryBySQLCompleted, 
            "processFailed": queryBySQLFailed 
            } 
    }); 
    queryBySQLService.processAsync(queryBySQLParams); 
    
    var queryParam1, queryBySQLParams1, queryBySQLService1; 
    queryParam1 = new SuperMap.REST.FilterParameter({ 
        name: "Aloha_Yellow_P@SDDY_GIS", 
        //attributeFilter: "tb_shuju.color='red'", 
        //attributeFilter: "SmID<7" ,
        fields: ["SmID","SMX","SMY"]
       // joinItems: [joinItem]
     }), 
    queryBySQLParams1 = new SuperMap.REST.QueryBySQLParameters({ 
         queryParams: [queryParam1] 
            }), 
    queryBySQLService1 = new SuperMap.REST.QueryBySQLService(url, { 
        eventListeners: { 
            "processCompleted": queryBySQLCompleted1, 
            "processFailed": queryBySQLFailed1 
            } 
    }); 
    queryBySQLService1.processAsync(queryBySQLParams1); 
    
    var queryParam2, queryBySQLParams2, queryBySQLService2; 
    queryParam2= new SuperMap.REST.FilterParameter({ 
        name: "Aloha_Orange_P@SDDY_GIS", 
        //attributeFilter: "tb_shuju.color='red'", 
        //attributeFilter: "SmID<7" ,
        fields: ["SmID","SMX","SMY"]
       // joinItems: [joinItem]
     }), 
    queryBySQLParams2 = new SuperMap.REST.QueryBySQLParameters({ 
         queryParams: [queryParam2] 
            }), 
    queryBySQLService2 = new SuperMap.REST.QueryBySQLService(url, { 
        eventListeners: { 
            "processCompleted": queryBySQLCompleted2, 
            "processFailed": queryBySQLFailed2 
            } 
    }); 
    queryBySQLService2.processAsync(queryBySQLParams2); 
	} 
function queryBySQLCompleted(queryEventArgs) {
  var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					var multiPoint=new SuperMap.Geometry.MultiPoint();
					var linearRings = new SuperMap.Geometry.LinearRing();
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取feature将其显示在Vector Layer上。
								var	feature	= new SuperMap.Feature.Vector();
								feature	= result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy=feature.attributes["SMY"];
                                var point=new SuperMap.Geometry.Point(pointx,pointy);
                                multiPoint.addPoint(point);
                                linearRings.addComponent(point);
								// 将属性值放入表格中
							}
						}
					}
							//	var region = new SuperMap.Geometry.Polygon([linearRings]);
								var	feature1= new SuperMap.Feature.Vector(linearRings,null,stylered);
								vectorLayer.addFeatures(feature1);
				}
				else{
							resultTable = "<p>无查询结果！</p>";
				}
				//alert(resultTable);
                //document.getElementById("queryResultPanel").innerHTML = resultTable;
			} 
		function queryBySQLFailed(e) {
		alert(e.error.errorMsg);
		}
		
		function queryBySQLCompleted1(queryEventArgs) {
  var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					var multiPoint=new SuperMap.Geometry.MultiPoint();
					var linearRings = new SuperMap.Geometry.LinearRing();
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取feature将其显示在Vector Layer上。
								var	feature	= new SuperMap.Feature.Vector();
								feature	= result.recordsets[i].features[k];
								feature.style =	styleyellow;
								//vectorLayer.addFeatures(feature);
								var pointx = feature.attributes["SMX"],
								pointy=feature.attributes["SMY"];
                                var point=new SuperMap.Geometry.Point(pointx,pointy);
                                multiPoint.addPoint(point);
                                linearRings.addComponent(point);
								}
							}
						}	
								var	feature1= new SuperMap.Feature.Vector(linearRings,null,styleyellow);
								vectorLayer.addFeatures(feature1);
								
				}
				else{
							resultTable = "<p>无查询结果！</p>";
				}
				//alert(resultTable);
               // document.getElementById("queryResultPanel").innerHTML = resultTable;
			} 
		function queryBySQLFailed1(e) {
		alert(e.error.errorMsg);
		}
		
		function queryBySQLCompleted2(queryEventArgs) {
  var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					var multiPoint=new SuperMap.Geometry.MultiPoint();
					var linearRings = new SuperMap.Geometry.LinearRing();
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取feature将其显示在Vector Layer上。
								var	feature	= new SuperMap.Feature.Vector();
								feature	= result.recordsets[i].features[k];
								feature.style =	styleorange;
								//vectorLayer.addFeatures(feature);
								var pointx = feature.attributes["SMX"],
								pointy=feature.attributes["SMY"];
                                var point=new SuperMap.Geometry.Point(pointx,pointy);
                                multiPoint.addPoint(point);
                                linearRings.addComponent(point);
								
								// 将属性值放入表格中
							}
						}
					}
								var	feature1= new SuperMap.Feature.Vector(linearRings,null,styleorange);
							//	alert(feature1);
								vectorLayer.addFeatures(feature1);
				}
				else{
							resultTable = "<p>无查询结果！</p>";
				}
				//alert(resultTable);
               // document.getElementById("queryResultPanel").innerHTML = resultTable;
			} 
			function queryBySQLFailed2(e) {
		alert(e.error.errorMsg);
		}
			
		// 加载图层
        function addLayer() {
			// 向Map添加图层
			var pointx=document.getElementById("pointx").value,
			pointy=document.getElementById("pointy").value;
// 			size = new SuperMap.Size(44, 33),
//             offset = new SuperMap.Pixel(-(size.w/2), -size.h),
//             icon = new SuperMap.Icon("IMG/supermap/marker.png", size, offset);
            if(pointx!="" && pointy!=""){
// 			var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon);            
//          markerLayer.addMarker(marker);
            map.addLayers([layer,vectorLayer,markerLayer]);
            map.setCenter(new SuperMap.LonLat(pointx, pointy), 4);
            }
            else{
            map.addLayers([layer,vectorLayer,markerLayer]);
            map.setCenter(new SuperMap.LonLat(534534.39070352 ,4216069.8492462), 4);
            }
           geo();
        }
        
          var infowin = null;
        function openInfoWin() {           
            closeInfoWin();
            var marker = this;            
            var lonlat = marker.lonlat;
              var contentHTML = "<div style='font-size:.8em; opacity: 0.8; overflow-y:hidden;'>";  
            contentHTML += "<div>"+lonlat+"</div></div>";  
            var popup = new SuperMap.Popup.FramedCloud("popwin",  
                new SuperMap.LonLat(lonlat.lon, lonlat.lat),  
                null,  
                contentHTML,  
                null,  
                true);  
            infowin = popup;  
            map.addPopup(popup);  
        }
        function closeInfoWin() {          
            if (infowin) {
                try {
                    infowin.hide();
                    infowin.destroy();
                }
                catch (e) { }
            }
        }
        function clickHandler() {
            closeInfoWin();
            var marker = this;
            var lonlat = marker.getLonLat(); 
            var contentHTML = "<div style=\'font-size:.8em; opacity: 0.8; overflow-y:hidden;\'>"; 
    		contentHTML += "<div>"+lonlat+"</div></div>"; 
		    var popup = new SuperMap.Popup.FramedCloud("popwin",new SuperMap.LonLat(lonlat.lon,lonlat.lat),null,contentHTML,null,true); 
		    map.addPopup(popup); 

        }
           function dblclickHandler() {
          	closeInfoWin();
			
			// 设置查询参数
            var queryParam, queryBySQLParams, queryBySQLService;
            //FilterParameter 必设 name（查询地图图层名），attributeFilter（SQL条件语句）也为必设
            queryParam = new SuperMap.REST.FilterParameter({
                name: "地块_Point@SDDY_GIS",
				fields:["SMID","SMX","SMY","name"]
            }),
			//QueryBySQLParameters 参数必设	queryParams
            queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url, {
                eventListeners: {"processCompleted":sqlCompleted, "processFailed": sqlFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
           }
           
            function sqlCompleted(queryEventArgs) {
            var result = queryEventArgs.result;

			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					var resultTable = "";
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							var arrFields = new Array();
							var intFieldCount = result.recordsets[i].fields.length;
							resultTable += "<table align='left' style='width: 600px' border='1'>";
							var strTableHead = ""; 
							// 将字段名称列于表格首行
							for (var n = 0;n < intFieldCount;n++)
							{ 										
										var fieldName = result.recordsets[i].fields[n];
										strTableHead += "<td>";
										strTableHead += fieldName;
										strTableHead += "</td>";
										arrFields.push(fieldName);
							}
							resultTable += "<tr>" + strTableHead + "</tr>";
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取feature将其显示在Vector Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(44, 33),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                icon = new SuperMap.Icon("IMG/supermap/marker.png", size, offset);
								markerLayer.addMarker(new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy), icon));
								// 将属性值放入表格中
								// 将属性值放入表格中
								resultTable += "<tr>";
								for(var	j=0;j<intFieldCount;j++){
									resultTable += "<td>";
									resultTable += feature.attributes[arrFields[j]];
									resultTable += "</td>";
								}
								resultTable += "</tr>";
							}
							resultTable += "</table>";
						}
					}
				}
				else{
							resultTable = "<p>无查询结果！</p>";
				}
                document.getElementById("queryResultPanel").innerHTML = resultTable;
		}
        function sqlFailed(e) {
            alert(e.error.errorMsg);
        }
		// 激活绘制面对象的操作
		 function drawGeometry() {
            //先清除上次的显示结果
            vectorLayer.removeAllFeatures();
            markerLayer.clearMarkers();
            drawPolygon.activate();
        }

		// 绘制面对象结束后处理函数,执行几何查询
		function drawPolygonCompleted(evnetArg){
			drawPolygon.deactivate();
		    // 获取绘制的对象，并显示在vector图层上
			var feature = new SuperMap.Feature.Vector();
            feature.geometry = evnetArg.feature.geometry,
            feature.style = style;
            vectorLayer.addFeatures(feature);
			// 设置查询参数
            var queryParam, queryByGeometryParameters, queryByGeoService;
            //FilterParameter 必设 name（查询地图图层名）
            var status =document.getElementById("status").value;
            if(status =="厂名")
            {
            queryParam = new SuperMap.REST.FilterParameter({
                name: "地块_Point@SDDY_GIS",
                fields:["SMID","NAME"]
            });
            }
            else if(status =="危险源")
            {
             queryParam = new SuperMap.REST.FilterParameter({
                name: "危险源_Point@SDDY_GIS",
                fields:["SMID","NAME"]
            });
            }
            else if(status =="摄像点")
            {
             queryParam = new SuperMap.REST.FilterParameter({
                name: "摄像点_Point@SDDY_GIS",
                fields:["SMID","NAME"]
            });
            }
            else if(status =="罐区")
            {
             queryParam = new SuperMap.REST.FilterParameter({
                name: "罐区_Point@SDDY_GIS",
                fields:["SMID","NAME"]
            });
            }
            else if(status =="仓库")
            {
             queryParam = new SuperMap.REST.FilterParameter({
                name: "仓库_Point@SDDY_GIS",
                fields:["SMID","NAME"]
            });
            }
            else if(status =="装置区")
            {
             queryParam = new SuperMap.REST.FilterParameter({
                name: "装置区_Point@SDDY_GIS",
                fields:["SMID","NAME"]
            });
            }
            else
            {
             queryParam = new SuperMap.REST.FilterParameter({
                name: "地块_Point@SDDY_GIS",
                fields:["SMID","NAME"]
            });
            }
			//QueryByGeometryParameters 参数必设	queryParams
             queryByGeometryParameters = new SuperMap.REST.QueryByGeometryParameters({
                queryParams: [queryParam],
				geometry:feature.geometry,
				spatialQueryMode: SuperMap.REST.SpatialQueryMode.INTERSECT
            }),

            queryByGeoService = new SuperMap.REST.QueryByGeometryService(url, {
                eventListeners: {"processCompleted": processCompleted, "processFailed": processFailed}});
            queryByGeoService.processAsync(queryByGeometryParameters);
        }
		// 获取查询结果
        function processCompleted(queryEventArgs) {
            var result = queryEventArgs.result;

			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					var resultTable = "";
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							var arrFields = new Array();
							var intFieldCount = result.recordsets[i].fields.length;
							resultTable += "<table align='left' style='width: 600px' border='1'>";
							var strTableHead = ""; 
							// 将字段名称列于表格首行
							for (var n = 0;n < intFieldCount;n++)
							{ 										
										var fieldName = result.recordsets[i].fields[n];
										strTableHead += "<td>";
										strTableHead += fieldName;
										strTableHead += "</td>";
										arrFields.push(fieldName);
							}
							resultTable += "<tr>" + strTableHead + "</tr>";
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var point = result.recordsets[i].features[k].geometry,
                                size = new SuperMap.Size(44, 33),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                icon = new SuperMap.Icon("IMG/supermap/marker.png", size, offset);
							//	markerLayer.addMarker(new SuperMap.Marker(new SuperMap.LonLat(point.x, point.y), icon));
								 var marker = new SuperMap.Marker(new SuperMap.LonLat(point.x, point.y),icon);            
            					 markerLayer.addMarker(marker);

					            //例如点击marker弹出popup            
					             marker.events.on({                 
					             "mouseover": openInfoWin,                 
					             "mouseout": closeInfoWin,                 
					             //"click": clickHandler,   
					             "dblclick":dblclickHandler,              
					             "scope": marker             
					               });
            
								// 将属性值放入表格中
								resultTable += "<tr>";
								for(var	j=0;j<intFieldCount;j++){
									resultTable += "<td>";
									var fName =arrFields[j];
									resultTable += feature.attributes[fName];
									resultTable += "</td>";
								}
								resultTable += "</tr>";
							}
							resultTable += "</table>";
						}
					}
				}
				else{
							resultTable = "<p>无查询结果！</p>";
				}
                document.getElementById("queryResultPanel").innerHTML = resultTable;
		}
        function processFailed(e) {
            alert(e.error.errorMsg);
        }
        function clearFeatures() {
            //先清除上次的显示结果
            vectorLayer.removeAllFeatures();
            vectorLayer.refresh();
            markerLayer.clearMarkers();
        }
        
         function drawPointGeo() {
            //先清除上次的显示结果
            vectorLayer.removeAllFeatures();
            markerLayer.clearMarkers();
            drawPoint.activate();
        }
        
        function drawPointCompleted(evnetArg){
			var feature = new SuperMap.Feature.Vector();
            feature.geometry = evnetArg.feature.geometry,
            feature.style = style;
            vectorLayer.addFeatures(feature);
            document.getElementById("getpointx").value=feature.geometry.x;
            document.getElementById("getpointy").value=feature.geometry.y;
            drawPoint.deactivate();
            }
        
        
      
		
        
    </script>
  </head>
  <body onload=onPageLoad() >
  <table cellpadding="0" CELLSPACING="0" class="toolbartable">
		<tr class="toolbartableline1">
			<td width="10"></td>
			<td>
				<a href="javascript:void(0)" class="easyui-linkbutton" 
					data-options="iconCls:'icon-dodel'" onclick="clearFeatures();">清除</a>
			</td>
			<td width="10"></td>
		</tr>
	</table>
		<br>
		<input  type ="hidden" id="pointx"  value="${param.valuex}">
	  	<input  type ="hidden" id="pointy"  value="${param.valuey}">
		<div id="map" style="position:relative;left:0px;right:0px;width:100%;height:100%;">             
     	</div>
	 	<div id="queryResultPanel" style="width:600px;left:10px;top:420px;">			
		</div>
		<input  type ="text" id="pointinformation"  value="">
  </body>
  <c:if test="${! empty msg}">
		<script>
			$.messager.alert('系统提示', '${msg}');
		</script>
	</c:if>
  
</html>

 
