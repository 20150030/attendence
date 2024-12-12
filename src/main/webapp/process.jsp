<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<%
	request.setCharacterEncoding("utf-8");
    // 선택된 체크박스 정보를 받아옴
    String[] checkedValues = request.getParameterValues("checkedValues");
	// 저정할 출석체크 날짜
    String insertDate = request.getParameter("insertDate");
    
    // JDBC 연결 및 처리
    Connection conn = null;
    PreparedStatement pstmtDelete = null;
    PreparedStatement pstmtInsert = null;

    try {

    	// JDBC 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/study?useSSL=false&allowPublicKeyRetrieval=true";
        String username = "root";
        String password = "1234";
        conn = DriverManager.getConnection(url, username, password);

        // 주어진 날짜에 해당하는 기존 출석 데이터를 전부 삭제
        String deleteQuery = "DELETE FROM attendance WHERE ATND_DATE = ?";
        pstmtDelete = conn.prepareStatement(deleteQuery);
        pstmtDelete.setString(1, insertDate);
        pstmtDelete.executeUpdate();

        // 새로운 출석 데이터를 삽입
        String insertQuery = "INSERT INTO attendance (SNO, ATND_DATE) VALUES (?, ?)";
        pstmtInsert = conn.prepareStatement(insertQuery);
        for (String sno : checkedValues) {
            pstmtInsert.setString(1, sno);
            pstmtInsert.setString(2, insertDate);
            pstmtInsert.executeUpdate();
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        // 자원 해제
        if (pstmtDelete != null) try { pstmtDelete.close(); } catch (SQLException ignore) {}
        if (pstmtInsert != null) try { pstmtInsert.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
    // 출석 저장 완료 메세지 표시 후 메인페이지로 이동
    out.println("<script>alert('출석을 저장하였습니다.'); location.href='main.jsp'; </script>");
%>