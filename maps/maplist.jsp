<%@ page language="java"   pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"/>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" >
		<link href="/SDDY/CSS/comm2.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="JS/comm.js"></script>
		<script type="text/javascript" src="My97DatePicker/WdatePicker.js"></script>
		<script src="maps/libs/SuperMap.Include.js"></script> 
		<script type="text/javascript" src="jquery-easyui-1.3.2/jquery-1.8.0.min.js"></script>
		<script type="text/javascript" src="jquery-easyui-1.3.2/jquery.easyui.min.js"></script>
		<script type="text/javascript" src="jquery-easyui-1.3.2/locale/easyui-lang-zh_CN.js"></script>
		<link rel="stylesheet" type="text/css" href="jquery-easyui-1.3.2/themes/default/easyui.css"/>
		<link rel="stylesheet" type="text/css" href="jquery-easyui-1.3.2/themes/icon.css"/>
	<script type="text/javascript">
	$(document).ready(function(){
		$('#dlg').dialog('close');
		$('.window-shadow').remove();	
		onPageLoad();
	});
  	var map, layer, vectorLayer,vectorLayer1,drawPoint,drawPoint1,drawLine,markerLayer,drawPolygon,drawPolygon1,mouseWheel,selectFeature,isdrag=false,
		    style = {
                pointRadius: 140,
                pointerEvents: "visiblePainted",
                fillColor: "#304DBE",
                fillOpacity: 0.8				
            },
             pointstyle = {
                pointRadius: 10,
                externalGraphic: "IMG/supermap/marker.png",
                pointerEvents: "visiblePainted",
                fillColor: "#304DBE",
                fillOpacity: 1.0				
            },
            stylepuff = {
               pointRadius: 1,
                strokeColor: "#000000",
				strokeOpacity: 1, 
                fillColor: "#000000",
                fillOpacity: 1				
            },
            selectStyle = {  
            fillColor: "#ffcc33",  
            strokeColor: "#ccff99",  
            strokeWidth: 2,  
            graphZIndex: 1  
        };  
    var stylestable = {  
            strokeColor: "#304DBE",  
            strokeOpacity: 0,  
            fillColor: "#00ff00",  
            fillOpacity: 0
        };  
	var infowin = null;
    var popups=new Array();
    var popupsrtu=new Array();
    var popupscamera=new Array();
 	var url1 = "${MAPSERVER}";
     // 设置访问的GIS服务地址   
	function onPageLoad() {
	// 创建图层对象
        layer = new SuperMap.Layer.TiledDynamicRESTLayer("东营港环境监控", url1, {transparent: true, cacheEnabled: true}, {maxResolution:"auto"}); 
        	vectorLayer = new SuperMap.Layer.Vector("面积层");
        	vectorLayer1 = new SuperMap.Layer.Vector("定位层");
        	markerLayer = new SuperMap.Layer.Markers("标记层");
        	drawLine = new SuperMap.Control.DrawFeature(vectorLayer,SuperMap.Handler.Path,{multi: false});
			//
			drawLine.events.on({"featureadded": drawlineCompleted});
			// 创建绘制面的控件
			drawPoint = new SuperMap.Control.DrawFeature(vectorLayer, SuperMap.Handler.Point);     
            drawPoint.events.on({"featureadded": drawPointCompleted});
            drawPoint1 = new SuperMap.Control.DrawFeature(vectorLayer, SuperMap.Handler.Point);     
            drawPoint1.events.on({"featureadded": drawPoint1Completed});
			// 创建图层对象
            drawPolygon1 = new SuperMap.Control.Measure(SuperMap.Handler.Polygon,{immediate: true});    
            drawPolygon1.events.on({"measure": drawmeasureCompleted});
            
            mouseWheel = new SuperMap.Control.Navigation({ 
                          dragPanOptions: {
                              enableKinetic: true
                          }
                          }, SuperMap.Handler.MouseWheel);
            //mouseWheel.events.on({"mousewheel": mousewheelCompleted});
            layer.events.on({"layerInitialized": addLayer});  
			// 加载鹰眼控件
			map = new SuperMap.Map("map",{
			        minScale:1/70000,
			        maxScale:4.828188529610221e-4,
			        restrictedExtent:new SuperMap.Bounds(525280.323131,4207350.897281,557487.927211,4224868.702635) ,
			        controls:[                      
                     new SuperMap.Control.ScaleLine(),
                     new SuperMap.Control.PanZoomBar(
                      {showSlider:true},
                      {forceFixedZoomLevel:true}
                      ),
		      		new SuperMap.Control.LayerSwitcher()]
            });	 
            map.addControl(new SuperMap.Control.OverviewMap({maximized: false}));
            map.addControl(new SuperMap.Control.KeyboardDefaults());   //支持键盘操作
			map.addControl(drawPolygon1);
			map.addControl(drawPoint);
			map.addControl(drawPoint1);
			map.addControl(drawLine);
			map.addControl(mouseWheel);
			selectFeature = new SuperMap.Control.SelectFeature(vectorLayer, {  
                onSelect: onFeatureSelect,  
                onUnselect: onUnFeatureSelect,  
                hover: true  
            });  
            map.addControl(selectFeature);  
            selectFeature.activate();  
}
		
		 	function onUnFeatureSelect(feature) {  
		 	if(document.getElementById("map")){
	       	document.getElementById("map").style.cursor="auto";
	       	}
            feature.style = stylestable;  
            vectorLayer.redraw();  
       		}  
        	function onFeatureSelect(feature) { 
        	if(document.getElementById("map")){
	       	document.getElementById("map").style.cursor="hand";
	       	}
            feature.style = selectStyle;  
            vectorLayer.redraw();  
        	}   
        	
        	function Initfactory() {  
            var queryParam, queryBySQLParams, queryBySQLService;  
            //SuperMap.REST.FilterParameter 查询过滤条件参数类。 该类用于设置查询数据集的查询过滤参数。   
            queryParam = new SuperMap.REST.FilterParameter({  
                name: "Factory_R@SDDY_GIS"  
            });  
            //SuperMap.REST.QueryBySQLParameters SQL 查询参数类。 该类用于设置 SQL 查询的相关参数。   
            queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({  
                queryParams: [queryParam]  
            });  
            //SuperMap.REST.QueryBySQLService SQL 查询服务类。 在一个或多个指定的图层上查询符合 SQL 条件的空间地物信息。   
            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {  
                eventListeners: { "processCompleted": factoryCompleted, "processFailed":factoryFailed }  
            });  
            queryBySQLService.processAsync(queryBySQLParams);  
        }  
        //查询成功  
        function factoryCompleted(queryEventArgs) {  
            var i, j, feature,  
                    result = queryEventArgs.result;  
            if (result && result.recordsets) {  
                for (i = 0; i < result.recordsets.length; i++) {  
                    if (result.recordsets[i].features) {  
                        for (j = 0; j < result.recordsets[i].features.length; j++) {  
                            feature = result.recordsets[i].features[j];  
                            feature.style = stylestable;  
                            vectorLayer.addFeatures(feature);  
                        }  
                    }  
                }  
            }  
        }  
        function factoryFailed(e) {  
            alert(e.error.errorMsg);  
        }
                
   //初始化     
  function Init() {
            changeitems();
           // Initfactory();
		}
  function addLayer() {
			// 向Map添加图层
			var pointx=document.getElementById("pointx").value,
			pointy=document.getElementById("pointy").value,
			size = new SuperMap.Size(44, 33),
            offset = new SuperMap.Pixel(-(size.w/2), -size.h),
            icon = new SuperMap.Icon("IMG/supermap/marker.png", size, offset);
            if(pointx!="" && pointy!=""){
			var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon);            
            markerLayer.addMarker(marker);
            map.addLayers([layer,vectorLayer1,vectorLayer,markerLayer]);
            map.setCenter(new SuperMap.LonLat(pointx, pointy), 3);
            }
            else{
            map.addLayers([layer,vectorLayer1,vectorLayer,markerLayer]);
            map.setCenter(new SuperMap.LonLat(534534.39070352 ,4216069.8492462), 4);
            }
            map.events.register("moveend",map, mousewheelendCompleted);
           // map.events.register("movestart",map, mousewheelstartCompleted);
           if (!('${param.name2}'!='' && '${param.name3}'!='')){
            Init();
            }
        }
		
//function addLayer() {
     // 向Map中添加图层
  //   map.addLayer(layer); 
     //显示地图范围 
  //   map.setCenter(new SuperMap.LonLat(1252.26 , 3613.98), 0);
     
//} 				
        // 放大
        function ZoomIn() {
            map.zoomIn();
        }

        // 缩小
        function ZoomOut() {
            map.zoomOut();
        }
     
		function drawlineCompleted(arguments){
				    drawLine.deactivate();
		            var geometry = arguments.feature.geometry,
					measureParam = new SuperMap.REST.MeasureParameters(geometry);
					
					var measureService = new SuperMap.REST.MeasureService(url1, {
													measureMode: SuperMap.REST.MeasureMode.DISTANCE,
													eventListeners:{'processCompleted': measurelineCompleted,'processFailed':measurelineFailed}
													});
					measureService.processAsync(measureParam);
				}

		function distancelineMeasure(){
			//
			 vectorLayer.removeAllFeatures();
			// 
			drawLine.activate();
		}

		// 
		function measurelineCompleted(measureEventArgs){
			//
			var distance = measureEventArgs.result.distance,
                unit = measureEventArgs.result.unit;
            if (distance != -1) {
                alert("距离为："+distance.toFixed(2)+"米");
            }
		}
		//
		function measurelineFailed(MeasureEventArgs){
		   alert("计算失败");
		}

		//执行SQL查询
		
        	// 绘制面对象结束后处理函数,执行几何查询
        
        
        
        function drawmeasureCompleted(arguments){
		    drawPolygon1.deactivate();
			alert("面积为"+arguments.measure.toFixed(2)+"平方米");
		}

		//
		function distanceofordrawMeasure(){
			// 
			vectorLayer.removeAllFeatures();
			//markerLayer.clearMarkers();
			drawPolygon1.activate();
		}
				
		
		// 激活绘制面对象的操作
		
        
         function drawPointGeo() {
            //先清除上次的显示结果
            vectorLayer.removeAllFeatures();
            vectorLayer1.removeAllFeatures();
            markerLayer.clearMarkers();
            drawPoint1.activate();
        }
        function drawGeometry() {
            //先清除上次的显示结果
           	vectorLayer.removeAllFeatures();
            vectorLayer1.removeAllFeatures();
            markerLayer.clearMarkers();
            drawPoint.activate();
        }
        
        function drawPointCompleted(evnetArg){
			drawPoint.deactivate();
             // 获取绘制的对象，并显示在vector图层上
			var feature = new SuperMap.Feature.Vector();
            feature.geometry = evnetArg.feature.geometry,
            feature.style = style;
            vectorLayer.addFeatures(feature);
            if(document.getElementById("status")!=null){
            var status =document.getElementById("status").value;
            if(status =="厂名")
            {
	            var queryParam = new SuperMap.REST.FilterParameter({
	                name: "地块_Point@SDDY_GIS",
	                fields:["SMX","SMY","SMID","NAME","SNAME","SID"]
	            });
	
				var queryByDistanceParams = new SuperMap.REST.QueryByDistanceParameters({
							queryParams:[queryParam],
							returnContent: true,
							distance: 1000,
							geometry: feature.geometry
						}); 
				
				var queryByDistanceService = new SuperMap.REST.QueryByDistanceService(url1);
				queryByDistanceService.events.on({
							"processCompleted": processCompleted,
							"processFailed": processFailed
						});
				queryByDistanceService.processAsync(queryByDistanceParams);
            }
            else if(status =="危险源-储罐")
            {
	            var queryParam1= new SuperMap.REST.FilterParameter({
	                name: "Danger_P@SDDY_GIS",
	                fields:["SMX","SMY","SMID","NAME","ADDR","TYPE"],
	                attributeFilter: "type='储罐'"
	            });
	
				var queryByDistanceParams1 = new SuperMap.REST.QueryByDistanceParameters({
							queryParams:[queryParam1],
							returnContent: true,
							distance: 1000,
							geometry: feature.geometry
						}); 
				
				var queryByDistanceService1 = new SuperMap.REST.QueryByDistanceService(url1);
				queryByDistanceService1.events.on({
							"processCompleted": process1Completed,
							"processFailed": processFailed
						});
				queryByDistanceService1.processAsync(queryByDistanceParams1);
			}
            else if(status =="摄像点")
            {
	            	var queryParam2= new SuperMap.REST.FilterParameter({
		         	      name: "Camera_P@SDDY_GIS",
		                fields:["SMX","SMY","SMID","NAME","CAID"]
		            });
		
					var queryByDistanceParams2 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam2],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService2 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService2.events.on({
								"processCompleted": process2Completed,
								"processFailed": processFailed
							});
					queryByDistanceService2.processAsync(queryByDistanceParams2);
            }
            else if(status =="气象监测点")
            {
		            var queryParam3= new SuperMap.REST.FilterParameter({
				                name: "RTUWeather_P@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME","CODE","TYPE","MPID"]
				            });
			
					var queryByDistanceParams3 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam3],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService3 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService3.events.on({
								"processCompleted": process7Completed,
								"processFailed": processFailed
							});
					queryByDistanceService3.processAsync(queryByDistanceParams3);
            }
            else if(status =="探头")
            {
            		var queryParam4= new SuperMap.REST.FilterParameter({
				                name: "RTUMonitor_P@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME","CODE","TYPE","MPID"]
				            });
			
					var queryByDistanceParams4 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam4],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService4 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService4.events.on({
								"processCompleted": process6Completed,
								"processFailed": processFailed
							});
					queryByDistanceService4.processAsync(queryByDistanceParams4);
            }
            else if(status =="危险源-罐区")
            {
            var queryParam5= new SuperMap.REST.FilterParameter({
				                name: "Danger_P@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME"],
				                attributeFilter: "type='罐区'"
				            });
			
					var queryByDistanceParams5 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam5],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService5 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService5.events.on({
								"processCompleted": process3Completed,
								"processFailed": processFailed
							});
					queryByDistanceService5.processAsync(queryByDistanceParams5);
            }
            else if(status =="危险源-危险品仓库")
            {
             		var queryParam6= new SuperMap.REST.FilterParameter({
				                name: "Danger_P@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME"],
				                attributeFilter: "type='危险品仓库'"
				            });
			
					var queryByDistanceParams6 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam6],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService6 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService6.events.on({
								"processCompleted": process4Completed,
								"processFailed": processFailed
							});
					queryByDistanceService6.processAsync(queryByDistanceParams6);
            }
            else if(status =="危险源-重点装置")
            {
             		var queryParam7= new SuperMap.REST.FilterParameter({
				                name: "Danger_P@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME"],
				                attributeFilter: "type='重点装置'"
				            });
			
					var queryByDistanceParams7 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam7],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService7 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService7.events.on({
								"processCompleted": process5Completed,
								"processFailed": processFailed
							});
					queryByDistanceService7.processAsync(queryByDistanceParams7);
            }
            else
            {
              var queryParam = new SuperMap.REST.FilterParameter({
	                name: "地块_Point@SDDY_GIS",
	                fields:["SMX","SMY","SMID","NAME","SNAME","SID"]
	            });
	
				var queryByDistanceParams = new SuperMap.REST.QueryByDistanceParameters({
							queryParams:[queryParam],
							returnContent: true,
							distance: 1000,
							geometry: feature.geometry
						}); 
				
				var queryByDistanceService = new SuperMap.REST.QueryByDistanceService(url1);
				queryByDistanceService.events.on({
							"processCompleted": processCompleted,
							"processFailed": processFailed
						});
				queryByDistanceService.processAsync(queryByDistanceParams);
           
	            var queryParam1= new SuperMap.REST.FilterParameter({
	                name: "Danger_P@SDDY_GIS",
	                fields:["SMX","SMY","SMID","NAME","ADDR","TYPE"]
	            });
	
				var queryByDistanceParams1 = new SuperMap.REST.QueryByDistanceParameters({
							queryParams:[queryParam1],
							returnContent: true,
							distance: 1000,
							geometry: feature.geometry
						}); 
				
				var queryByDistanceService1 = new SuperMap.REST.QueryByDistanceService(url1);
				queryByDistanceService1.events.on({
							"processCompleted": process1Completed,
							"processFailed": processFailed
						});
				queryByDistanceService1.processAsync(queryByDistanceParams1);
			
	            	var queryParam2= new SuperMap.REST.FilterParameter({
		         	      name: "Camera_P@SDDY_GIS",
		                fields:["SMX","SMY","SMID","NAME","CAID"]
		            });
		
					var queryByDistanceParams2 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam2],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService2 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService2.events.on({
								"processCompleted": process2Completed,
								"processFailed": processFailed
							});
					queryByDistanceService2.processAsync(queryByDistanceParams2);
           
		            var queryParam3= new SuperMap.REST.FilterParameter({
				                name: "RTUWeather_P@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME","CODE","TYPE","MPID"]
				            });
			
					var queryByDistanceParams3 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam3],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService3 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService3.events.on({
								"processCompleted": process7Completed,
								"processFailed": processFailed
							});
					queryByDistanceService3.processAsync(queryByDistanceParams3);
           
            		var queryParam4= new SuperMap.REST.FilterParameter({
				                name: "RTUMonitor_P@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME","CODE","TYPE","MPID"]
				            });
			
					var queryByDistanceParams4 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam4],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService4 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService4.events.on({
								"processCompleted": process6Completed,
								"processFailed": processFailed
							});
					queryByDistanceService4.processAsync(queryByDistanceParams4);
            
            var queryParam5= new SuperMap.REST.FilterParameter({
				                name: "罐区_Point@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME"]
				            });
			
					var queryByDistanceParams5 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam5],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService5 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService5.events.on({
								"processCompleted": process3Completed,
								"processFailed": processFailed
							});
					queryByDistanceService5.processAsync(queryByDistanceParams5);
           
//              		var queryParam6= new SuperMap.REST.FilterParameter({
// 				                name: "仓库_Point@SDDY_GIS",
// 				                fields:["SMX","SMY","SMID","NAME"]
// 				            });
			
// 					var queryByDistanceParams6 = new SuperMap.REST.QueryByDistanceParameters({
// 								queryParams:[queryParam6],
// 								returnContent: true,
// 								distance: 1000,
// 								geometry: feature.geometry
// 							}); 
					
// 					var queryByDistanceService6 = new SuperMap.REST.QueryByDistanceService(url1);
// 					queryByDistanceService6.events.on({
// 								"processCompleted": process4Completed,
// 								"processFailed": processFailed
// 							});
// 					queryByDistanceService6.processAsync(queryByDistanceParams6);
           
             		var queryParam7= new SuperMap.REST.FilterParameter({
				                name: "装置区_Point@SDDY_GIS",
				                fields:["SMX","SMY","SMID","NAME"]
				            });
			
					var queryByDistanceParams7 = new SuperMap.REST.QueryByDistanceParameters({
								queryParams:[queryParam7],
								returnContent: true,
								distance: 1000,
								geometry: feature.geometry
							}); 
					
					var queryByDistanceService7 = new SuperMap.REST.QueryByDistanceService(url1);
					queryByDistanceService7.events.on({
								"processCompleted": process5Completed,
								"processFailed": processFailed
							});
					queryByDistanceService7.processAsync(queryByDistanceParams7);
            }    	  
	         	}
            }
        		
        function drawPoint1Completed(evnetArg){
			var feature = new SuperMap.Feature.Vector();
            feature.geometry = evnetArg.feature.geometry,
            feature.style=pointstyle;
            vectorLayer1.addFeatures(feature);
            document.getElementById("pointx").value=feature.geometry.x;
            document.getElementById("pointy").value=feature.geometry.y;
            drawPoint1.deactivate();
            }
       
       //各类marker的特殊事件相应     
        function overInfoWin() {
        if(document.getElementById("map")){
       	document.getElementById("map").style.cursor="hand";
       	}
        }
        function outInfoWin() {
        if(document.getElementById("map")){
       	document.getElementById("map").style.cursor="auto";
       	}
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
        
        //点击危险源显示
        function clickHandler(){
        	var e = event || window.event; 
         	var x=e.clientX;
        	var y=e.clientY;
        	closeInfoWin();
            var marker=this;
            var lonlat=marker.getLonLat();
            var contentHTML =" <ul style='margin-bottom: 5px'>";
            contentHTML +=  "<div style=\'font-size:14px;text-align:left;overflow-y:hidden;\'>"; 
    		contentHTML += "<div>名称："+marker.name+"</div></div></ul>";
// 		    var popup = new SuperMap.Popup.FramedCloud("popwin",new SuperMap.LonLat(lonlat.lon,lonlat.lat),null,contentHTML,null,true);
// 		    infowin = popup;  
// 		    map.addPopup(popup); 
			document.getElementById("dlg").innerHTML = contentHTML;
			$('.panel-title').html(marker.name);
			$('.panel').attr("style"," position: absolute; width: 400px; display: block;height:200px;  top:"+y+"; left:"+x+";");
			$('#dlg').dialog('open');
        }
        function showfactory() {
        	var e = event || window.event;
        	var x=e.clientX;
        	var y=e.clientY;
            closeInfoWin();
            var marker=this;
            var contentHTML ="<div style=\'background-color: #D3E6F5;height:300px;\'><div style=\'background-color: #D3E6F5;height:150px;text-align:left;overflow-y:hidden;\'><table>"; 
            $.post("MapsAction.do?method=showfactorydetails&id="+marker.sid,function(data){
				//alert(data);
				var datas=data.split(";");
				for(var i=0;i<datas.length;i++){
					var data=datas[i].split(":")[0];
					var val1=datas[i].split(":")[1];
					
					if(i==4)
					{
						contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>"+data+":</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+val1+"<td></tr></table></div>";
					} 
					else if(i==5)
					{	
						if(val1!=null&&val1!="0")
						{
							contentHTML += "<div style=\'background-color:#A6C2D8;height:80px;text-align:left;overflow-y:hidden;margin-left:20px;margin-right:20px;\'><table><tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;cursor:hand;'onclick='showcameradetails(\""+marker.sid+"\")'><img src='IMG/dongying/camera.jpg' />"+data+"</td><td style='text-align:left;text-font-size:12px;color:#FFFFFF;padding-left:30px;padding-right:30px;'>"+val1+"<td>";
						}
						else
						{
							contentHTML += "<div style=\'background-color:#A6C2D8;height:80px;text-align:left;overflow-y:hidden;margin-left:20px;margin-right:20px;\'><table><tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;cursor:hand;'><img src='IMG/dongying/camera.jpg' />"+data+"</td><td style='text-align:left;text-font-size:12px;color:#FFFFFF;padding-left:30px;padding-right:30px;'>"+val1+"<td>";
						}
						
					}
					else if(i==6)
					{
						if(val1!=null&&val1!="0")
						{
							contentHTML += "<td style='text-align:left;text-font-size:12px;font-weight:bold;color:#085D9E;cursor:hand;'onclick='showmonitordetails(\""+marker.sid+"\",\""+marker.name+"\")'><img src='IMG/dongying/probe.jpg'/>"+data+"</td><td style='text-align:left;text-font-size:12px;color:#FFFFFF;padding-left:30px;padding-right:30px;'>"+val1+"<td></tr>";
						}
						else
						{
							contentHTML += "<td style='text-align:left;text-font-size:12px;font-weight:bold;color:#085D9E;cursor:hand;'><img src='IMG/dongying/probe.jpg'/>"+data+"</td><td style='text-align:left;text-font-size:12px;color:#FFFFFF;padding-left:30px;padding-right:30px;'>"+val1+"<td></tr>";
						}
					
					}
					else if(i==7)
					{
						if(val1!=null&&val1!="0")
						{
							contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;cursor:hand;'onclick='showweatherdetails(\""+marker.sid+"\",\""+marker.name+"\")'><img src='IMG/dongying/weather.jpg'/>"+data+"</td><td style='text-align:left;text-font-size:12px;color:#FFFFFF;padding-left:30px;padding-right:30px;'>"+val1+"<td>";
						}
						else
						{
							contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;cursor:hand;'><img src='IMG/dongying/weather.jpg'/>"+data+"</td><td style='text-align:left;text-font-size:12px;color:#FFFFFF;padding-left:30px;padding-right:30px;'>"+val1+"<td>";
						}
						
					}
					else if(i==8)
					{
						if(val1!=null&&val1!="0")
						{
							contentHTML += "<td style='text-align:left;text-font-size:12px;font-weight:bold;color:#085D9E;cursor:hand;'onclick='showdangerdetails(\""+marker.sid+"\")'><img src='IMG/dongying/danger.jpg'/>"+data+"</td><td style='text-align:left;text-font-size:12px;color:#FFFFFF;padding-left:30px;padding-right:30px;'>"+val1+"<td></tr>";
						}
						else
						{
							contentHTML += "<td style='text-align:left;text-font-size:12px;font-weight:bold;color:#085D9E;cursor:hand;'><img src='IMG/dongying/danger.jpg'/>"+data+"</td><td style='text-align:left;text-font-size:12px;color:#FFFFFF;padding-left:30px;padding-right:30px;'>"+val1+"<td></tr>";
						}
					
					}
					else
					{
						contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>"+data+":</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+val1+"<td></tr>";
					} 
					}
				contentHTML += "</table></div></div>"; 
 				document.getElementById("dlg").innerHTML = contentHTML;
				$('.panel-title').html(marker.name);
				//$('.panel-header').attr("style","background-color: #D3E6F5;width: 388px;");
				$('.panel').attr("style"," position: absolute; width: 400px; display: block;height:300px;background-color: #D3E6F5;  top:"+y+"; left:"+x+";");
				//alert($('#dlg').html());
				$('#dlg').dialog('open');
			});
			
        }
		  //点击摄像点显示
        function clickCamera(){
         	var e = event || window.event; 
         	var x=window.event.screenX;
         		if(x<500){x=500;}
        	var y=e.clientY;
        	var marker=this;
        	window.open("cameraction.do?method=camview&id="+marker.id+"",null,"top=200,left="+x+",status=no,toolbar=no,menubar=no,location=no,resizable=yes");	
        }
        
        //点击危险源显示
        function showdanger(){
        	var e = event || window.event; 
         	var x=e.clientX;
        	var y=e.clientY;
        	closeInfoWin();
            var marker=this;
            var lonlat=marker.getLonLat();
            var contentHTML ="<div style=\'background-color: #D3E6F5;height:300px;\'><div style=\'background-color: #D3E6F5;height:300px;text-align:left;overflow-y:hidden;\'>";
            contentHTML +=  "<table><tr>"; 
    		contentHTML += "<td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>名称：</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+marker.name+"</td></tr>"; 
    		contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>类型：</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+marker.type+"</td></tr>";
    		contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>地址：</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+marker.addr+"</td></tr><table></div>";
// 		    var popup = new SuperMap.Popup.FramedCloud("popwin",new SuperMap.LonLat(lonlat.lon,lonlat.lat),null,contentHTML,null,true);
// 		    infowin = popup;  
// 		    map.addPopup(popup); 
			document.getElementById("dlg").innerHTML = contentHTML;
			$('.panel-title').html(marker.name);
			$('.panel').attr("style"," position: absolute; width: 400px; display: block;height:300px;  top:"+y+"; left:"+x+";");
			$('#dlg').dialog('open');
        }
        
        //点击探头显示
        function showmonitor(){
        	var e = event || window.event; 
         	var x=e.clientX;
        	var y=e.clientY;
        	closeInfoWin();
            var marker=this;
            var lonlat=marker.getLonLat();
            var code=marker.code;
            var id=marker.id;
            var contentHTML = "<div style=\'background-color: #D3E6F5;height:300px;\'><div style=\'background-color: #D3E6F5;height:150px;text-align:left;overflow-y:hidden;\'><table>"; 
            contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>类型：</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+marker.name+"</td></tr>";
            var xmlobj =  new ActiveXObject("Microsoft.XMLHTTP");
			var post = " ";
			xmlobj.open("POST","MapsAction.do?method=showmonitordetails&tablename="+code,false);
			xmlobj.setrequestheader("content-length", post.length);
			xmlobj.setrequestheader("content-type", "application/x-www-form-urlencoded");
			xmlobj.send(post);
			var res = xmlobj.responseText;
			if(res!=null && res!="" &&  res!="error"){
				var json = eval('(' + res + ')');	
				if(json!=null){
					contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>数值：</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+json[0].value0+"</td></tr>";
				}	
			}else{
				return;
			} 
			//contentHTML +='<SPAN class=l-btn-left sizset="false" sizcache05330249159192983="4.0.1"><SPAN class="l-btn-text icon-edit l-btn-icon-left">历史数据</SPAN></SPAN>';
    		//contentHTML +='<div style=\'cursor:hand;\' onclick="monitordetails(\''+id+'\')"><button> 历史数据</button> </div></div>';
   			//contentHTML +='<a href="javascript:void(0)" class="easyui-linkbutton"  id="history" data-options="iconCls:\'icon-edit\'" onclick="monitordetails(\''+id+'\')">历史数据</a>';
		    contentHTML +='</table></div>';
		    var toolHTML='<DIV id=tb class=dialog-toolbar>'
		    +'<A class="easyui-linkbutton l-btn l-btn-plain" onclick="monitordetails(\''+id+'\')" href="#" data-options="iconCls:\'icon-edit\',plain:true" sizset="true" sizcache08182550272043896="10.0.1">'
		    +'<SPAN class=l-btn-left sizset="false" sizcache08182550272043896="10.0.1">'
		    +'<SPAN class="l-btn-text icon-edit l-btn-icon-left">历史曲线</SPAN></SPAN></A></DIV>';
		   document.getElementById("dlg").innerHTML =toolHTML+contentHTML;
			$('.panel-title').html(marker.name);
			$('.panel').attr("style"," position: absolute; width: 400px; display: block;height:300px;  top:"+y+"; left:"+x+";");
			$('#dlg').dialog('open');
//  		    var popup = new SuperMap.Popup.FramedCloud("popwin",new SuperMap.LonLat(lonlat.lon,lonlat.lat),new SuperMap.Size(200,200),contentHTML,null,true);
//  		    popup.setBorder("gray ridge 1px");
//  		    infowin = popup;  
//  		    map.addPopup(popup);
		
        }
        
        function monitordetails(id){
        	window.open("SummaryHyInfoAction.do?method=showUnit&id="+id);
        }
         //点击气象监测点显示
        function showweather(){
        	var e = event || window.event; 
         	var x=e.clientX;
        	var y=e.clientY;
        	closeInfoWin();
            var marker=this;
            var lonlat=marker.getLonLat();
            var code=marker.code;
            var id=marker.id;
            var contentHTML = "<div style=\'background-color: #D3E6F5;height:300px;\'><div style=\'background-color: #D3E6F5;height:150px;text-align:left;overflow-y:hidden;\'><table>"; 
            contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>类型：</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+marker.name+"</td></tr>";
            var xmlobj =  new ActiveXObject("Microsoft.XMLHTTP");
			var post = " ";
			xmlobj.open("POST","MapsAction.do?method=showweatherdetails&tablename="+code,false);
			xmlobj.setrequestheader("content-length", post.length);
			xmlobj.setrequestheader("content-type", "application/x-www-form-urlencoded");
			xmlobj.send(post);
			var res = xmlobj.responseText;
			if(res!=null && res!="" &&  res!="error"){
				var json = eval('(' + res + ')');	
				if(json!=null){
					contentHTML += "<tr><td style='text-align:right;text-font-size:12px;font-weight:bold;color:#085D9E;padding-left:20px;'>数值：</td><td style='text-align:left;text-font-size:12px;color:#000000;background-color:#FFFFFF;padding-left:20px;width:260px;'>"+json[0].value0+"</td></tr>";
				}	
			}else{
				return;
			}
    		contentHTML +='</table></div>';
    		var toolHTML='<DIV id=tb class=dialog-toolbar>'
		    +'<A class="easyui-linkbutton l-btn l-btn-plain" onclick="weatherdetails(\''+id+'\')" href="#" data-options="iconCls:\'icon-edit\',plain:true" sizset="true" sizcache08182550272043896="10.0.1">'
		    +'<SPAN class=l-btn-left sizset="false" sizcache08182550272043896="10.0.1">'
		    +'<SPAN class="l-btn-text icon-edit l-btn-icon-left">历史曲线</SPAN></SPAN></A></DIV>';
		   document.getElementById("dlg").innerHTML =toolHTML+contentHTML;
			$('.panel-title').html(marker.name);
			$('.panel').attr("style"," position: absolute; width: 400px; display: block;height:300px;  top:"+y+"; left:"+x+";");
			$('#dlg').dialog('open');
// 		    var popup = new SuperMap.Popup.FramedCloud("popwin",new SuperMap.LonLat(lonlat.lon,lonlat.lat),null,contentHTML,null,true);
// 		    infowin = popup;  
// 		    map.addPopup(popup);
        }
        
         function weatherdetails(id){
        	window.open("SummaryHyInfoAction.do?method=showUnit&id="+id);
        }
        
        
        //初始化厂信息
        function Initfactoryitems(){
            var queryParam=null, queryBySQLParams, queryBySQLService;
            if(document.getElementById("searchitems")!=null){
            	var searchitems =document.getElementById("searchitems").value;
            	//FilterParameter 必设 name（查询地图图层名）
            	queryParam = new SuperMap.REST.FilterParameter({
                name: "地块_Point@SDDY_GIS",
                attributeFilter: "Name LIKE '%" + searchitems + "%'"
           		 });
	         	} 
			//QueryByGeometryParameters 参数必设	queryParams
             queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {
                eventListeners: {"processCompleted":processCompleted, "processFailed": processFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
        }
		// 获取查询结果
        function processCompleted(queryEventArgs) {
            var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(20, 20),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                name =feature.attributes["SNAME"];
					            var icon = new SuperMap.Icon("IMG/dongying/factory/factory_round.png", size, offset);
								var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon); 
								marker.name =name; 
								marker.sid=feature.attributes["SID"];         
	            				markerLayer.addMarker(marker);
	
						        //例如点击marker弹出popup            
						        marker.events.on({                 
						        "click":showfactory,                
	 					        "mouseover":overInfoWin ,
	 					        "mouseout":outInfoWin ,              
						        "scope": marker             
						        });
							}
						}
					}
				}
				else{
				}
		}
        function processFailed(e) {
            alert(e.error.errorMsg);
        }
        
        //初始化危险源储罐信息
        function Initdangeritems(){
         var queryParam=null, queryBySQLParams, queryBySQLService;
            if(document.getElementById("searchitems")!=null){
            	var searchitems =document.getElementById("searchitems").value;
            	//FilterParameter 必设 name（查询地图图层名）
            	queryParam = new SuperMap.REST.FilterParameter({
                name: "Danger_P@SDDY_GIS",
                attributeFilter: "type='储罐' and name LIKE '%" + searchitems + "%' "
           		 });
	         	} 
			//QueryByGeometryParameters 参数必设	queryParams
             queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {
                eventListeners: {"processCompleted":process1Completed, "processFailed": processFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
        }
		// 获取查询结果
        function process1Completed(queryEventArgs) {
            var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(20, 20),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                name =feature.attributes["NAME"];
                                addr =feature.attributes["ADDR"];
                                type =feature.attributes["TYPE"];
					            var icon = new SuperMap.Icon("IMG/dongying/chuguan.png", size, offset);
								var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon); 
								marker.name =name; 
								marker.addr =addr; 
								marker.type =type;     
	            				markerLayer.addMarker(marker);
	
						        //例如点击marker弹出popup            
						        marker.events.on({                 
						        "click":showdanger,                
	 					        "mouseover":overInfoWin ,
	 					        "mouseout":outInfoWin ,              
						        "scope": marker             
						        });
            
							}
						}
					}
				}
				else{
				}
		}
        
         //初始化摄像点信息
        function Initcameraitems(){
             var queryParam=null, queryBySQLParams, queryBySQLService;
            if(document.getElementById("searchitems")!=null){
            	var searchitems =document.getElementById("searchitems").value;
            	//FilterParameter 必设 name（查询地图图层名）
            	queryParam = new SuperMap.REST.FilterParameter({
                name: "Camera_P@SDDY_GIS",
                attributeFilter: "name LIKE '%" + searchitems + "%'"
           		 });
	         	} 
			//QueryByGeometryParameters 参数必设	queryParams
             queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {
                eventListeners: {"processCompleted":process2Completed, "processFailed": processFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
        }
		// 获取查询结果
        function process2Completed(queryEventArgs) {
            var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(20, 20),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                name =feature.attributes["NAME"];
					            var icon = new SuperMap.Icon("IMG/dongying/shexiangtou.png", size, offset);
							 	var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon); 
								marker.id =feature.attributes["CAID"];
	            				markerLayer.addMarker(marker);
	
						        //例如点击marker弹出popup            
						        marker.events.on({                 
						        "click":clickCamera, 
						        "mouseover":overInfoWin, 
						        "mouseout":outInfoWin,              
						        "scope": marker             
						        });
            
							}
						}
					}
				}
				else{
				}
		}
        
          //初始化危险源罐区信息
        function Inittankitems(){
         var queryParam=null, queryBySQLParams, queryBySQLService;
            if(document.getElementById("searchitems")!=null){
            	var searchitems =document.getElementById("searchitems").value;
            	//FilterParameter 必设 name（查询地图图层名）
            	queryParam = new SuperMap.REST.FilterParameter({
                name: "Danger_P@SDDY_GIS",
                attributeFilter: "type='罐区' and name LIKE '%" + searchitems + "%'"
           		 });
	         	} 
			//QueryByGeometryParameters 参数必设	queryParams
             queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {
                eventListeners: {"processCompleted":process3Completed, "processFailed": processFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
        }
		// 获取查询结果
        function process3Completed(queryEventArgs) {
            var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(20, 20),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                name =feature.attributes["NAME"];
                                addr =feature.attributes["ADDR"];
                                type =feature.attributes["TYPE"];
					            var icon = new SuperMap.Icon("IMG/dongying/guanqu.png", size, offset);
								var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon); 
								marker.name =name; 
								marker.addr =addr; 
								marker.type =type;  
	            				markerLayer.addMarker(marker);
	
						        //例如点击marker弹出popup            
						        marker.events.on({                 
						        "click":showdanger,                
	 					        "mouseover":overInfoWin ,
	 					        "mouseout":outInfoWin ,              
						        "scope": marker             
						        });
            
							}
						}
					}
				}
				else{
				}
		}
		
		 //初始化危险品仓库信息
        function Initstoreitems(){
         var queryParam=null, queryBySQLParams, queryBySQLService;
            if(document.getElementById("searchitems")!=null){
            	var searchitems =document.getElementById("searchitems").value;
            	//FilterParameter 必设 name（查询地图图层名）
            	queryParam = new SuperMap.REST.FilterParameter({
                name: "Danger_P@SDDY_GIS",
                attributeFilter: "type='危险品仓库'and name LIKE '%" + searchitems + "%'"
           		 });
	         	} 
			//QueryByGeometryParameters 参数必设	queryParams
             queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {
                eventListeners: {"processCompleted":process4Completed, "processFailed": processFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
        }
		// 获取查询结果
        function process4Completed(queryEventArgs) {
            var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(20, 20),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                name =feature.attributes["NAME"];
                                addr =feature.attributes["ADDR"];
                                type =feature.attributes["TYPE"];
					            var icon = new SuperMap.Icon("IMG/dongying/cangku.png", size, offset);
								var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon); 
								marker.name =name; 
								marker.addr =addr; 
								marker.type =type;     
	            				markerLayer.addMarker(marker);
	
						        //例如点击marker弹出popup            
						        marker.events.on({                 
						        "click":showdanger,                
	 					        "mouseover":overInfoWin ,
	 					        "mouseout":outInfoWin ,              
						        "scope": marker             
						        });
            
							}
						}
					}
				}
				else{
				}
		}
		
		//初始化危险源重点装置信息
        function Initdeviceitems(){
             var queryParam=null, queryBySQLParams, queryBySQLService;
            if(document.getElementById("searchitems")!=null){
            	var searchitems =document.getElementById("searchitems").value;
            	//FilterParameter 必设 name（查询地图图层名）
            	queryParam = new SuperMap.REST.FilterParameter({
                name: "Danger_P@SDDY_GIS",
                attributeFilter: "type='重点装置' and name LIKE '%" + searchitems + "%'"
           		 });
	         	} 
			//QueryByGeometryParameters 参数必设	queryParams
             queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {
                eventListeners: {"processCompleted":process5Completed, "processFailed": processFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
        }
		// 获取查询结果
        function process5Completed(queryEventArgs) {
            var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(20, 20),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                name =feature.attributes["NAME"];
                                addr =feature.attributes["ADDR"];
                                type =feature.attributes["TYPE"];
					            var icon = new SuperMap.Icon("IMG/dongying/zhuangzhi.png", size, offset);
								var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon); 
								marker.name =name; 
								marker.addr =addr; 
								marker.type =type;   
	            				markerLayer.addMarker(marker);
	
						        //例如点击marker弹出popup            
						        marker.events.on({                 
						        "click":showdanger,                
	 					        "mouseover":overInfoWin ,
	 					        "mouseout":outInfoWin ,              
						        "scope": marker             
						        });
            
							}
						}
					}
				}
				else{
				}
		}
		
		//初始化探头信息
        function Initmonitoritems(){
         var queryParam=null, queryBySQLParams, queryBySQLService;
            if(document.getElementById("searchitems")!=null){
            	var searchitems =document.getElementById("searchitems").value;
            	//FilterParameter 必设 name（查询地图图层名）
            	queryParam = new SuperMap.REST.FilterParameter({
                name: "RTUMonitor_P@SDDY_GIS",
                attributeFilter: "name LIKE '%" + searchitems + "%'"
           		 });
	         	} 
			//QueryByGeometryParameters 参数必设	queryParams
             queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {
                eventListeners: {"processCompleted":process6Completed, "processFailed": processFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
        }
		// 获取查询结果
        function process6Completed(queryEventArgs) {
            var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(20, 20),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                name =feature.attributes["NAME"];
                                type=feature.attributes["TYPE"];
                                code =feature.attributes["CODE"];
                                id =feature.attributes["MPID"];
					            var icon = new SuperMap.Icon("IMG/dongying/tantou.png", size, offset);
								var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon); 
								marker.name =name;
								marker.code=code; 
								marker.id=id;    
	            				markerLayer.addMarker(marker);
	
						        //例如点击marker弹出popup            
						        marker.events.on({                 
						        "click":showmonitor,                
	 					        "mouseover":overInfoWin ,
	 					        "mouseout":outInfoWin ,              
						        "scope": marker             
						        });
            
							}
						}
					}
				}
				else{
				}
		}
		
		//初始化气象监测点信息
        function Initweatheritems(){
           var queryParam=null, queryBySQLParams, queryBySQLService;
            if(document.getElementById("searchitems")!=null){
            	var searchitems =document.getElementById("searchitems").value;
            	//FilterParameter 必设 name（查询地图图层名）
            	queryParam = new SuperMap.REST.FilterParameter({
                name: "RTUWeather_P@SDDY_GIS",
                attributeFilter: "name LIKE '%" + searchitems + "%'"
           		 });
	         	} 
			//QueryByGeometryParameters 参数必设	queryParams
             queryBySQLParams = new SuperMap.REST.QueryBySQLParameters({
                queryParams: [queryParam]
            }),

            queryBySQLService = new SuperMap.REST.QueryBySQLService(url1, {
                eventListeners: {"processCompleted":process7Completed, "processFailed": processFailed}});
            queryBySQLService.processAsync(queryBySQLParams);
        }
		// 获取查询结果
        function process7Completed(queryEventArgs) {
            var result = queryEventArgs.result;
			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var pointx = feature.attributes["SMX"],
								pointy = feature.attributes["SMY"],
                                size = new SuperMap.Size(20, 20),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                name =feature.attributes["NAME"];
                                type =feature.attributes["TYPE"];
                                code =feature.attributes["CODE"];
                                id =feature.attributes["MPID"];
					            var icon = new SuperMap.Icon("IMG/dongying/qixiang.png", size, offset);
								var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon); 
								marker.name =name;
								marker.code=code; 
								marker.id=id;        
	            				markerLayer.addMarker(marker);
	
						        //例如点击marker弹出popup            
						        marker.events.on({                 
						        "click":showweather,                
	 					        "mouseover":overInfoWin ,
	 					        "mouseout":outInfoWin ,              
						        "scope": marker             
						        });
            
							}
						}
					}
				}
				else{
				}
		}
		// 初始化所有特殊点位信息
		function Initallitems(){
			Initfactoryitems();
            Initdangeritems();
            Initcameraitems();
            Inittankitems();
            Initstoreitems();
            Initdeviceitems();
            Initmonitoritems();
            Initweatheritems();
		}
		
		
		//鼠标滚轮监听
         function mousewheelendCompleted(e){
         $('#dlg').dialog('close');
           var scale=map.getScale();
	         	if(scale>(1/8284.68063222648)){
	         	}
	         	if(scale<(1/8284.68063222648)){
	         	}
	        }
	        
	      //下拉框监听  
	      function changeitems(){
	      	markerLayer.clearMarkers();
	      	closeInfoWin();
	      	$('#dlg').dialog('close');	
	     	if(document.getElementById("status")!=null){
            var status =document.getElementById("status").value;
            if(status =="厂名")
            {
            Initfactoryitems();
            }
            else if(status =="危险源-储罐")
            {
            Initdangeritems();
            }
            else if(status =="摄像点")
            {
             Initcameraitems();
            }
            else if(status =="气象监测点")
            {
             Initweatheritems();
            }
            else if(status =="探头")
            {
             Initmonitoritems();
            }
            else if(status =="危险源-罐区")
            {
            Inittankitems();
            }
            else if(status =="危险源-危险品仓库")
            {
             Initstoreitems();
            }
            else if(status =="危险源-重点装置")
            {
             Initdeviceitems();
            }
            else
            {
             Initallitems();
            }    	  
	         	}
	         	}
	         	
	         	
	    //清除按钮功能     	
        function clearFeatures() {
            //先清除上次的显示结果
            vectorLayer.removeAllFeatures();
            vectorLayer.refresh();
            vectorLayer1.removeAllFeatures();
            vectorLayer1.refresh();
            markerLayer.clearMarkers();
            closeInfoWin();
            document.getElementById("queryResultPanel").innerHTML = "<td></td>";
            $('#dlg').dialog('close');	
        }
        
        
        //定位确定按钮功能
         function closewindow() {
            //先清除上次的显示结果
            if(document.getElementById("pointx").value!="" && document.getElementById("pointy").value!=""&& document.getElementById("smid").value!=""){
              window.opener.document.getElementById("${param.name2}").value=document.getElementById("pointx").value;
            window.opener.document.getElementById("${param.name3}").value=document.getElementById("pointy").value;
            window.opener.document.getElementById("${param.name1}").value=document.getElementById("smid").value;
            }
             else if(document.getElementById("pointx").value!="" && document.getElementById("pointy").value!=""){
            window.opener.document.getElementById("${param.name2}").value=document.getElementById("pointx").value;
            window.opener.document.getElementById("${param.name3}").value=document.getElementById("pointy").value;
            }
            
            window.close();
        }
        
        //地图信息更新
        //厂区信息更新
        function doSync(){
			document.ListForm.action="MapsAction.do?method=dosync";
			document.ListForm.submit(); 	
		}
		 //探头信息更新
         function doSyncformonitor(){
			document.ListForm.action="MapsAction.do?method=dosyncformonitor";
			document.ListForm.submit(); 	
		}
		 //气象信息更新
		 function doSyncforweather(){
			document.ListForm.action="MapsAction.do?method=dosyncforweather";
			document.ListForm.submit(); 	
		}
         //摄像点信息更新
          function doSyncforcamera(){
			document.ListForm.action="MapsAction.do?method=dosyncforcamera";
			document.ListForm.submit(); 	
		}
		 //危险源信息更新
		   function doSyncfordanger(){
			document.ListForm.action="MapsAction.do?method=dosyncfordanger";
			document.ListForm.submit(); 	
		}
		 //烟团信息更新
         function dopuff(){
			document.ListForm.action="MapsAction.do?method=dopuff";
			document.ListForm.submit(); 	
		}
		
		 function showcameradetails(id){
		 var x=window.event.screenX;
         		if(x<500){x=500;}
        	window.open("cameraction.do?method=showlist&bizid=1&factoryid="+id,null,"top=200,left="+x+",status=no,toolbar=no,menubar=no,location=no,resizable=yes");
        }
        
        
		  function showmonitordetails(id,name){
		 var x=window.event.screenX;
         		if(x<500){x=500;}
		 window.open("SummaryHyInfoAction.do?method=showUnitFactoryAll&factoryid="+id+"&factoryname="+name+"&type=monitor",null,"top=200,left="+x+",status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes");
        }
        
        function showweatherdetails(id,name){
		 var x=window.event.screenX;
         		if(x<500){x=500;}
		 window.open("SummaryHyInfoAction.do?method=showUnitFactoryAll&factoryid="+id+"&factoryname="+name+"&type=weather",null,"top=200,left="+x+",status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes");
        }
        
        function showdangerdetails(id){
		 var x=window.event.screenX;
         		if(x<500){x=500;}
		 window.open("emgcySource.do?method=showlistforgis&factoryid="+id,null,"top=200,left="+x+",status=no,toolbar=no,menubar=no,location=no,resizable=yes");
        }
</script>
<style type="text/css">
<!--
.itemdiv {
	background-color: #D3E6F5;
	width:250px;
}
.contentdiv {
	font-size: 12px;
	border: 1px solid #4c76a1;
	background-color: #ddedfa;
	width:915px;
	margin-left:10px;
	margin-bottom: 5px;
}
.leftitemdiv {
	font-size: 14px;
	color:#085D9E;
	background-color: #D3E6F5;
	padding-top:10px;
	width:50px;
}

.rightitemdiv {
	font-size: 14px;
	color:#000000;
	background-color:#FFFFFF;
	padding-top:10px;
	width:200px;
}



</style>
</head>
<body >
	<form id="ListForm"  name="ListForm"  action="MapsAction.do?method=showlist"
			method="post">
<table  class="toolbartable" style="width:100%; margin:0px;" >
		<tr class="toolbartableline1" style="width:100%;">
			<td>
				<c:if test="${param.name2!=null && param.name3!=null}">
				<a href="javascript:void(0)" class="easyui-linkbutton" 
					data-options="iconCls:'icon-dosearch'" onclick="drawPointGeo();">寻点 </a>
				&nbsp;
				<a href="javascript:void(0)" class="easyui-linkbutton" 
					data-options="iconCls:'icon-doedit'" onclick="closewindow();">定位确定 </a>
				&nbsp;
				</c:if>
				<c:if test="${!(param.name2!=null && param.name3!=null)}">
				<select name="status" id="status" onchange="changeitems();">
				<option value="厂名">
					厂名
				</option>
				<option value="危险源-危险品仓库">
					危险源-危险品仓库
				</option>
				<option value="危险源-罐区">
					危险源-罐区
				</option>
				<option value="危险源-储罐">
					危险源-储罐
				</option>
				<option value="危险源-重点装置">
					危险源-重点装置
				</option>
				<option value="摄像点">
					摄像点
				</option>
				<option value="探头">
					探头
				</option>
				<option value="气象监测点">
					气象监测点
				</option>
				<option value="全部">
					全部
				</option>
				</select>
				&nbsp;	
				<input  type ="text" id="searchitems"  value="">
				<a href="javascript:void(0)" class="easyui-linkbutton" 
					data-options="iconCls:'icon-search'" onclick="changeitems();">查询</a>
				&nbsp;	
				<a href="javascript:void(0)" class="easyui-linkbutton" 
					data-options="iconCls:'icon-search'" onclick="drawGeometry();">区域查询</a>
				&nbsp;
				<a href="javascript:void(0)" class="easyui-linkbutton" 
					data-options="iconCls:'icon-edit'" onclick="distancelineMeasure();">距离查询</a>
				&nbsp;	
				<a href="javascript:void(0)" class="easyui-linkbutton" 
					data-options="iconCls:'icon-edit'" onclick="distanceofordrawMeasure();">求面积 </a>
				&nbsp;
				</c:if>
				<a href="javascript:void(0)" class="easyui-linkbutton"  id="clear"
					data-options="iconCls:'icon-dodel'" onclick="clearFeatures();">清除</a>
				&nbsp;
				<c:if test="${!(param.name2!=null && param.name3!=null)}">
				<a href="javascript:void(0)" class="easyui-linkbutton" 
							data-options="iconCls:'icon-reload'" onclick="doSync();">厂信息导入</a>
				&nbsp;
				<a href="javascript:void(0)" class="easyui-linkbutton" 
							data-options="iconCls:'icon-reload'" onclick="doSyncformonitor();">探头信息导入</a>
				&nbsp;
				<a href="javascript:void(0)" class="easyui-linkbutton" 
							data-options="iconCls:'icon-reload'" onclick="doSyncforweather();">气象信息导入</a>
				&nbsp;
				<a href="javascript:void(0)" class="easyui-linkbutton" 
							data-options="iconCls:'icon-reload'" onclick="doSyncforcamera();">摄像头信息导入</a>
				&nbsp;
				<a href="javascript:void(0)" class="easyui-linkbutton" 
							data-options="iconCls:'icon-reload'" onclick="doSyncfordanger();">危险源信息导入</a>
				&nbsp;
				<a href="javascript:void(0)" class="easyui-linkbutton" 
							data-options="iconCls:'icon-reload'" onclick="dopuff();">烟团导入</a>	
				</c:if>		
			</td>
		</tr>
	</table>
	</form>
		 	<input  type ="hidden" id="pointx"  value="${param.valuex}">
		  	<input  type ="hidden" id="pointy"  value="${param.valuey}">
	 		<input  type ="hidden" id="smid"  value="">
	 <div id="map" style="position:relative;left:0px;right:0px;width:100%;height:94%;">             
     </div>
     	<div id="queryResultPanel" style="top:415px;" ></div>
     	
     	
     	<div id="dlg" class="easyui-dialog"   data-options=" title:'详细信息', iconCls:'' " style="width:400px;height:300px;padding:10px;background-color: #D3E6F5;">
		</div>
</body>
<c:if test="${! empty msg}">
		<script>
			$.messager.alert('系统提示', '${msg}');
		</script>
	</c:if>

</html>
 

 
