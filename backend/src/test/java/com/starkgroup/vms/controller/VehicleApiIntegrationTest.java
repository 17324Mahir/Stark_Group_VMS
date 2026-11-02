package com.starkgroup.vms.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.starkgroup.vms.domain.VehicleStatus;
import com.starkgroup.vms.dto.CreateVehicleRequest;
import com.starkgroup.vms.dto.UpdateVehicleRequest;
import com.starkgroup.vms.repository.VehicleRepository;
import com.starkgroup.vms.service.JwtService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.ArrayList;
import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class VehicleApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private JwtService jwtService;

    private String authToken;
    private final List<Long> createdVehicleIds = new ArrayList<>();

    @BeforeEach
    void setUp() {
        authToken = "Bearer " + jwtService.generateToken("test@starkgroup.test");
    }

    @AfterEach
    void tearDown() {
        for (Long id : createdVehicleIds) {
            vehicleRepository.deleteById(id);
        }
        createdVehicleIds.clear();
    }

    @Test
    @DisplayName("Complete HTTP + PostgreSQL workflow: create, get, list, update, duplicate 409, and delete 404")
    void completeVehicleLifecycleHttpWorkflow() throws Exception {
        // 1. Create a vehicle
        CreateVehicleRequest createRequest = new CreateVehicleRequest(
                "  it-veh-1001  ",
                "Stark Aviation",
                "Jet",
                "Stark Industries",
                "Mark I",
                VehicleStatus.ACTIVE
        );

        MvcResult createResult = mockMvc.perform(post("/api/vehicles")
                        .header("Authorization", authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", containsString("/api/vehicles/")))
                .andExpect(jsonPath("$.id", notNullValue()))
                .andExpect(jsonPath("$.vehicleNumber", is("IT-VEH-1001")))
                .andExpect(jsonPath("$.company", is("Stark Aviation")))
                .andExpect(jsonPath("$.status", is("ACTIVE")))
                .andReturn();

        JsonNode createdJson = objectMapper.readTree(createResult.getResponse().getContentAsString());
        Long vehicleId = createdJson.get("id").asLong();
        createdVehicleIds.add(vehicleId);

        // 2. Fetch that vehicle by ID
        mockMvc.perform(get("/api/vehicles/{id}", vehicleId)
                        .header("Authorization", authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(vehicleId.intValue())))
                .andExpect(jsonPath("$.vehicleNumber", is("IT-VEH-1001")));

        // 3. Fetch list and confirm vehicle appears
        mockMvc.perform(get("/api/vehicles")
                        .header("Authorization", authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].vehicleNumber", hasItem("IT-VEH-1001")));

        // 4. Update the vehicle
        UpdateVehicleRequest updateRequest = new UpdateVehicleRequest(
                "IT-VEH-1001",
                "Stark Space",
                "Rocket",
                "Stark Industries",
                "Mark II",
                VehicleStatus.MAINTENANCE
        );

        mockMvc.perform(put("/api/vehicles/{id}", vehicleId)
                        .header("Authorization", authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(vehicleId.intValue())))
                .andExpect(jsonPath("$.company", is("Stark Space")))
                .andExpect(jsonPath("$.type", is("Rocket")))
                .andExpect(jsonPath("$.model", is("Mark II")))
                .andExpect(jsonPath("$.status", is("MAINTENANCE")));

        // 5. Fetch again and confirm persistence
        mockMvc.perform(get("/api/vehicles/{id}", vehicleId)
                        .header("Authorization", authToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.company", is("Stark Space")))
                .andExpect(jsonPath("$.status", is("MAINTENANCE")));

        // 6. Attempt a duplicate Vehicle Number and confirm 409 Conflict
        CreateVehicleRequest duplicateRequest = new CreateVehicleRequest(
                "it-veh-1001",
                "Stark Defense",
                "Tank",
                "Stark Industries",
                "Armor",
                VehicleStatus.ACTIVE
        );

        mockMvc.perform(post("/api/vehicles")
                        .header("Authorization", authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(duplicateRequest)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status", is(409)))
                .andExpect(jsonPath("$.code", is("DUPLICATE_VEHICLE_NUMBER")));

        // 7. Verify update-to-duplicate behavior
        CreateVehicleRequest secondCreate = new CreateVehicleRequest(
                "IT-VEH-2002",
                "Stark Logistics",
                "Van",
                "Ford",
                "Transit",
                VehicleStatus.ACTIVE
        );

        MvcResult secondResult = mockMvc.perform(post("/api/vehicles")
                        .header("Authorization", authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(secondCreate)))
                .andExpect(status().isCreated())
                .andReturn();

        Long secondId = objectMapper.readTree(secondResult.getResponse().getContentAsString()).get("id").asLong();
        createdVehicleIds.add(secondId);

        // Try updating second vehicle to the first vehicle's number
        UpdateVehicleRequest secondUpdate = new UpdateVehicleRequest(
                "it-veh-1001",
                "Stark Logistics",
                "Van",
                "Ford",
                "Transit",
                VehicleStatus.ACTIVE
        );

        mockMvc.perform(put("/api/vehicles/{id}", secondId)
                        .header("Authorization", authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(secondUpdate)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code", is("DUPLICATE_VEHICLE_NUMBER")));

        // 8. Delete the created vehicle
        mockMvc.perform(delete("/api/vehicles/{id}", vehicleId)
                        .header("Authorization", authToken))
                .andExpect(status().isNoContent());

        // 9. Fetch the deleted ID and confirm 404
        mockMvc.perform(get("/api/vehicles/{id}", vehicleId)
                        .header("Authorization", authToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code", is("VEHICLE_NOT_FOUND")));

        // Clean up second vehicle via HTTP DELETE
        mockMvc.perform(delete("/api/vehicles/{id}", secondId)
                        .header("Authorization", authToken))
                .andExpect(status().isNoContent());
        createdVehicleIds.clear();
    }
}

