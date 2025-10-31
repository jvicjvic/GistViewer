//
//  GistsListVMTests.swift
//  GistViewerTests
//
//  Created by jvic on 31/10/25.
//

import XCTest
import Combine
@testable import GistViewer

@MainActor
final class GistsListVMTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: GistsListVM!
    var mockRepository: MockGistRepository!
    var mockRouter: MockGistListRouter!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockRepository = MockGistRepository()
        mockRouter = MockGistListRouter()
        cancellables = Set<AnyCancellable>()
        
        sut = GistsListVM(router: mockRouter, repository: mockRepository)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
        mockRouter = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    // MARK: - Testes de Estado Inicial
    
    func testInitialState() {
        // Then
        XCTAssertTrue(sut.gists.isEmpty, "Gists devem estar vazios inicialmente")
        XCTAssertFalse(sut.isLoading, "Não deve estar carregando inicialmente")
        XCTAssertNil(sut.errorMessage, "Mensagem de erro deve ser nil inicialmente")
        XCTAssertEqual(sut.title, "Gists", "Título deve ser 'Gists'")
    }
    
    // MARK: - Testes de Conexão
    
    func testConnect_Success_LoadsGists() async {
        // Given
        let mockGists = TestHelpers.createMockGists(count: 3)
        mockRepository.mockGists = mockGists
        
        let expectation = expectation(description: "Gists carregados")
        
        sut.$gists
            .dropFirst() // Pula o valor inicial vazio
            .sink { gists in
                if !gists.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.connect()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertTrue(mockRepository.fetchPublicGistsCalled, "Repository deve ser chamado")
        XCTAssertEqual(mockRepository.fetchPublicGistsCallCount, 1, "Repository deve ser chamado uma vez")
        XCTAssertEqual(mockRepository.fetchPublicGistsPages, [1], "Deve buscar a página 1")
        XCTAssertEqual(sut.gists.count, 3, "Deve ter 3 gists")
        XCTAssertEqual(sut.gists, mockGists, "Gists devem corresponder aos dados mock")
        XCTAssertFalse(sut.isLoading, "Não deve estar carregando após conclusão")
        XCTAssertNil(sut.errorMessage, "Mensagem de erro deve ser nil em caso de sucesso")
    }
    
    func testConnect_Failure_SetsErrorMessage() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(
            domain: "TestError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Erro de rede"]
        )
        
        let expectation = expectation(description: "Mensagem de erro definida")
        
        sut.$errorMessage
            .compactMap { $0 }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.connect()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertTrue(mockRepository.fetchPublicGistsCalled, "Repository deve ser chamado")
        XCTAssertTrue(sut.gists.isEmpty, "Gists devem permanecer vazios em caso de erro")
        XCTAssertFalse(sut.isLoading, "Não deve estar carregando após erro")
        XCTAssertNotNil(sut.errorMessage, "Mensagem de erro deve ser definida")
        XCTAssertEqual(sut.errorMessage, "Erro de rede", "Mensagem de erro deve corresponder")
    }
    
    // MARK: - Testes de Paginação
    
    func testDidReachEnd_LoadsNextPage() async {
        // Given
        let firstPageGists = TestHelpers.createMockGists(count: 3, startingId: 1)
        let secondPageGists = TestHelpers.createMockGists(count: 3, startingId: 4)
        
        mockRepository.mockGists = firstPageGists
        
        let firstLoadExpectation = expectation(description: "Primeira página carregada")
        
        sut.$gists
            .dropFirst()
            .sink { gists in
                if gists.count == 3 {
                    firstLoadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.connect()
        await fulfillment(of: [firstLoadExpectation], timeout: 2.0)
        
        // When - Carrega segunda página
        mockRepository.mockGists = secondPageGists
        
        let secondLoadExpectation = expectation(description: "Segunda página carregada")
        
        sut.$gists
            .sink { gists in
                if gists.count == 6 {
                    secondLoadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.didReachEnd()
        
        // Then
        await fulfillment(of: [secondLoadExpectation], timeout: 2.0)
        
        XCTAssertEqual(mockRepository.fetchPublicGistsCallCount, 2, "Deve chamar repository duas vezes")
        XCTAssertEqual(mockRepository.fetchPublicGistsPages, [1, 2], "Deve buscar páginas 1 e 2")
        XCTAssertEqual(sut.gists.count, 6, "Deve ter 6 gists no total")
        
        // Verifica que gists são adicionados, não substituídos
        XCTAssertEqual(sut.gists[0].id, "gist1", "Primeiro gist deve ser da página 1")
        XCTAssertEqual(sut.gists[3].id, "gist4", "Quarto gist deve ser da página 2")
    }

    
    func testLoadAvatar_Success_ReturnsImage() async {
        // Given
        let mockGist = TestHelpers.createMockGist()
        let mockImage = UIImage(systemName: "person.circle")
        mockRepository.mockAvatarImage = mockImage
        
        // When
        let result = await sut.loadAvatar(gist: mockGist)
        
        // Then
        XCTAssertTrue(mockRepository.fetchAvatarImageCalled, "Repository deve ser chamado")
        XCTAssertEqual(mockRepository.fetchAvatarImageCallCount, 1, "Deve chamar uma vez")
        XCTAssertNotNil(result, "Deve retornar uma imagem")
        XCTAssertEqual(result, mockImage, "Deve retornar a imagem mock")
        XCTAssertNil(sut.errorMessage, "Mensagem de erro deve ser nil em caso de sucesso")
    }
    
    func testLoadAvatar_Failure_ReturnsNilAndSetsError() async {
        // Given
        let mockGist = TestHelpers.createMockGist()
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NSError(
            domain: "TestError",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Avatar não encontrado"]
        )
        
        // When
        let result = await sut.loadAvatar(gist: mockGist)
        
        // Then
        XCTAssertTrue(mockRepository.fetchAvatarImageCalled, "Repository deve ser chamado")
        XCTAssertNil(result, "Deve retornar nil em caso de erro")
        XCTAssertNotNil(sut.errorMessage, "Mensagem de erro deve ser definida")
        XCTAssertEqual(sut.errorMessage, "Avatar não encontrado", "Mensagem de erro deve corresponder")
    }
    
    // MARK: - Testes de Seleção
    
    func testDidSelect_ValidIndex_NavigatesToDetail() {
        // Given
        let mockGists = TestHelpers.createMockGists(count: 3)
        mockRepository.mockGists = mockGists
        
        // Define gists manualmente para simular estado carregado
        sut.connect()
        
        // Aguarda um pouco pela operação assíncrona
        let expectation = expectation(description: "Gists carregados")
        sut.$gists
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // When
        sut.didSelect(index: 1)
        
        // Then
        XCTAssertTrue(mockRouter.navigateToCalled, "Router deve ser chamado")
        XCTAssertEqual(mockRouter.navigateToCallCount, 1, "Router deve ser chamado uma vez")
        XCTAssertEqual(mockRouter.lastNavigatedGist?.id, "gist2", "Deve navegar para o segundo gist")
    }
    
    func testDidSelect_FirstItem_NavigatesCorrectly() {
        // Given
        let mockGists = TestHelpers.createMockGists(count: 3)
        mockRepository.mockGists = mockGists
        
        sut.connect()
        
        let expectation = expectation(description: "Gists carregados")
        sut.$gists
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // When
        sut.didSelect(index: 0)
        
        // Then
        XCTAssertTrue(mockRouter.navigateToCalled, "Router deve ser chamado")
        XCTAssertEqual(mockRouter.lastNavigatedGist?.id, "gist1", "Deve navegar para o primeiro gist")
    }
    
    func testDidSelect_LastItem_NavigatesCorrectly() {
        // Given
        let mockGists = TestHelpers.createMockGists(count: 3)
        mockRepository.mockGists = mockGists
        
        sut.connect()
        
        let expectation = expectation(description: "Gists carregados")
        sut.$gists
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // When
        sut.didSelect(index: 2)
        
        // Then
        XCTAssertTrue(mockRouter.navigateToCalled, "Router deve ser chamado")
        XCTAssertEqual(mockRouter.lastNavigatedGist?.id, "gist3", "Deve navegar para o terceiro gist")
    }
}

