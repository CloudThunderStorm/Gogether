package backend;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter 
{
	
	
    @Override
    protected void configure(HttpSecurity http) throws Exception 
    {
    	http
        .authorizeRequests()
        	.antMatchers("/**")
            .permitAll()
            .anyRequest().authenticated()
            .and()
        .formLogin()
            .loginPage("/login")
            .permitAll()
            .and()
        .logout()
            .permitAll();
    	
    	// disable CSRF for POST API
    	http.csrf().disable();
    }

    @Autowired
    public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception 
    {
        
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://");
        dataSource.setUsername("");
        dataSource.setPassword("");
        
        auth.jdbcAuthentication().dataSource(dataSource)
			.usersByUsernameQuery("SELECT userName, userPassword, status FROM userInfo WHERE userName = ?")
			.authoritiesByUsernameQuery("SELECT userName, role FROM userInfo WHERE userName = ?");
			
    }
}

