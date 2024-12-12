<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>출석체크</title>
    <!-- Bootstrap CSS -->
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <style>
        body {
            background-color: #f8f9fa;
        }
        .container {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        .table thead th {
            background-color: #007bff;
            color: #ffffff;
        }
        .table tbody tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .table tbody tr:hover {
            background-color: #e9ecef;
        }
        .form-check-input {
            margin-left: 0;
        }
        .heading {
            color: #007bff;
        }
    </style>
</head>
<%
	// 쿼리 작성 및 실행
	String selectedDate = request.getParameter("selectedDate");
	if (selectedDate == null || selectedDate.isEmpty()) {
	    selectedDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
	}
	System.out.println("selectedDate : "+selectedDate);
%>
<body>
    <div class="container mt-5">
        <h2 class="mb-4 heading">출석체크</h2>
        <!-- Date Picker Form -->
        <form method="GET" class="mb-4" id="searchForm">
            <div class="form-group">
                <label for="date">날짜를 선택하세요.</label>
                <input type="date" class="form-control"  style="width:180px;" onchange="changeDate();" id="selectedDate" name="selectedDate" value="<%= selectedDate %>">
            </div>
           <!--  <button type="submit" class="btn btn-primary">검색</button> -->
        </form>
        <form method="POST" action="process.jsp" id="insertForm">
        	<input type="hidden" name="insertDate" value="<%= selectedDate %>"/>
	        <table class="table table-bordered">
	            <thead>
	                <tr>
	                    <th>학년</th>
	                    <th>반</th>
	                    <th>학번</th>
	                    <th>학생이름</th>
	                    <th>출석일</th>                    
	                    <th>출석체크</th>
	                </tr>
	            </thead>
				<tbody>
	                <%
	                    // JDBC 연결 설정
	                    Connection conn = null;
	                    PreparedStatement pstmt = null;
	                    ResultSet rs = null;
	                    try {
	                        // JDBC 연결
	                        Class.forName("com.mysql.cj.jdbc.Driver");
	                        String url = "jdbc:mysql://localhost:3306/study?useSSL=false&allowPublicKeyRetrieval=true";
	                        String username = "root";
	                        String password = "1234";
	
	                        // 데이터베이스 연결
	                        conn = DriverManager.getConnection(url, username, password);
	                        
	                        String query = "SELECT A.SNO, A.SNAME, A.SGRADE, A.SCLASS";
	                        query 		+= ", CASE WHEN B.SNO IS NULL THEN 'N' ELSE 'Y' END as ATND_YN";
	                        query 		+= ", CASE WHEN B.ATND_DATE IS NULL THEN '-' ELSE B.ATND_DATE END as ATND_DATE";
	                        query 		+= " FROM student A";
	                        query 		+= " LEFT OUTER JOIN attendance B";
	                        query 		+= " ON A.SNO = B.SNO";
	                        query 		+= " AND B.ATND_DATE = ?	";
	                        query 		+= " ORDER BY A.SGRADE ASC, A.SCLASS ASC, A.SNO ASC";
	                        
	                        System.out.println("query : "+query);
	                        pstmt = conn.prepareStatement(query);
	                        
	                        if (selectedDate != null && !selectedDate.isEmpty()) {
	                            pstmt.setString(1, selectedDate);
	                        }
	
	                        rs = pstmt.executeQuery();
							int index = 0;
	                        // 결과를 테이블 행으로 출력
	                        while (rs.next()) {
	                        	index++;
	                            String sno = rs.getString("SNO");
	                            String sname = rs.getString("SNAME");
	                            String sgrade = rs.getString("SGRADE");
	                            String sclass = rs.getString("SCLASS");
	                            String atndYn = rs.getString("ATND_YN");
	                            String atndDate = rs.getString("ATND_DATE");
	                         %>
	                <tr>
	                    <td><%= sgrade %></td>
	                    <td><%= sclass %></td>
	                    <td><%= sno %></td>
	                    <td><%= sname %></td>
	                    <td><%= atndDate %></td>
	                    <td><input id="chk_<%=index%>"  name="checkedValues" type="checkbox" value="<%=sno%>" class="form-check-input" <%= "Y".equals(atndYn) ? "checked" : "" %> ></td>
	                </tr>
	                <%
	                        }
	                    } catch (Exception e) {
	                        e.printStackTrace();
	                    } finally {
	                        // 자원 해제
	                        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
	                        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
	                        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
	                    }
	                %>
	            </tbody>
	        </table>
	        <button id="submitBtn" class="btn btn-primary mt-3">출석 저장</button>
	        <!-- <button id="submitBtn" onclick="$('#insertForm').submit();" class="btn btn-primary mt-3">출석 저장</button> -->
        </form>
    </div>
    <!-- Bootstrap JS, Popper.js, and jQuery -->
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
	<script src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.12.4.min.js"></script>
	<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
	    $(document).ready(function() {
	        // 출석체크 완료 버튼 클릭 시
	        
	        
	        $('#submitBtn').click(function() {
	        	$('#insertForm').submit();
	        });
	        
	  /*       $("#selectedDate").change(function(){
	        	
	        	$("#searchForm").submit();
	        }); */
	        
/* 	        $("#submitBtn").on('change', function(){
	        	
	        }) */
	        
	    });
	    
	    function changeDate(){
	    	//alert('testfunction');
	    	$("#searchForm").submit();
	    }
	    /* 체크박스 풀었을때 저장.
	    function saveAttend(){
        	$('#insertForm').submit();
	    } */
    </script>
</body>
</html>